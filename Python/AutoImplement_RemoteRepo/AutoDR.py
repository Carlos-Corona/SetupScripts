#!/usr/bin/env python3
"""
AUTO REPOSITORY SYNC (AutoDR)

This script verifies the hash of the last commit and compares it locally.
If there are changes, it will automatically pull the latest version.
Ensures the repository is on the head of the selected branch.

Designed for:
- Cron jobs
- Periodic execution 
- Manual execution
- Linux environments

Author: Improved version
License: MIT
"""

import requests
import os
import sys
import subprocess
import argparse
import json
import logging
from pathlib import Path
from typing import Dict, Optional, Tuple
from datetime import datetime
import configparser

# Configure logging for both file and console output
def setup_logging(log_level: str = "INFO", log_file: Optional[str] = None) -> logging.Logger:
    """Setup logging configuration"""
    logger = logging.getLogger("AutoDR")
    logger.setLevel(getattr(logging, log_level.upper()))
    
    # Clear existing handlers
    logger.handlers.clear()
    
    # Create formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # File handler if specified
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger

class AutoRepoSync:
    """Automatic Repository Synchronization Manager"""
    
    def __init__(self, config_path: str = "config.ini"):
        self.config_path = config_path
        self.config = self.load_config()
        self.logger = setup_logging(
            self.config.get('logging', 'level', fallback='INFO'),
            self.config.get('logging', 'file', fallback=None)
        )
        
    def load_config(self) -> configparser.ConfigParser:
        """Load configuration from file or create default"""
        config = configparser.ConfigParser()
        
        if os.path.exists(self.config_path):
            config.read(self.config_path)
        else:
            # Create default config
            config['repository'] = {
                'url': 'https://github.com/your_username/your_repository.git',
                'branch': 'main',
                'local_path': '.',
                'token': ''
            }
            config['logging'] = {
                'level': 'INFO',
                'file': 'auto_repo_sync.log'
            }
            config['options'] = {
                'force_pull': 'false',
                'backup_local_changes': 'true',
                'auto_stash': 'true'
            }
            
            with open(self.config_path, 'w') as f:
                config.write(f)
            
            print(f"Created default config file: {self.config_path}")
            print("Please update the configuration with your repository details.")
            
        return config
    
    def run_git_command(self, command: list, cwd: str = None) -> Tuple[bool, str, str]:
        """Execute git command and return success status, stdout, stderr"""
        try:
            result = subprocess.run(
                command,
                cwd=cwd or self.config.get('repository', 'local_path'),
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
        except subprocess.TimeoutExpired:
            self.logger.error(f"Git command timed out: {' '.join(command)}")
            return False, "", "Command timed out"
        except Exception as e:
            self.logger.error(f"Error running git command: {e}")
            return False, "", str(e)
    
    def get_remote_commit_hash(self) -> Optional[str]:
        """Get the latest commit hash from remote repository"""
        repo_url = self.config.get('repository', 'url')
        branch = self.config.get('repository', 'branch')
        token = self.config.get('repository', 'token')
        
        if not repo_url:
            self.logger.error("Repository URL not configured")
            return None
            
        # Extract owner and repo name from URL
        if repo_url.endswith('.git'):
            repo_url = repo_url[:-4]
        
        parts = repo_url.split('/')
        if len(parts) < 2:
            self.logger.error("Invalid repository URL format")
            return None
            
        owner = parts[-2]
        repo = parts[-1]
        
        api_url = f"https://api.github.com/repos/{owner}/{repo}/commits/{branch}"
        
        headers = {}
        if token:
            headers['Authorization'] = f'token {token}'
            
        try:
            response = requests.get(api_url, headers=headers, timeout=30)
            response.raise_for_status()
            
            commit_data = response.json()
            return commit_data['sha']
            
        except requests.RequestException as e:
            self.logger.error(f"Failed to fetch remote commit: {e}")
            return None
    
    def get_local_commit_hash(self) -> Optional[str]:
        """Get current local commit hash"""
        success, stdout, stderr = self.run_git_command(['git', 'rev-parse', 'HEAD'])
        if success:
            return stdout
        else:
            self.logger.error(f"Failed to get local commit hash: {stderr}")
            return None
    
    def get_current_branch(self) -> Optional[str]:
        """Get current branch name"""
        success, stdout, stderr = self.run_git_command(['git', 'branch', '--show-current'])
        if success:
            return stdout
        else:
            self.logger.error(f"Failed to get current branch: {stderr}")
            return None
    
    def is_repo_clean(self) -> bool:
        """Check if working directory is clean"""
        success, stdout, stderr = self.run_git_command(['git', 'status', '--porcelain'])
        if success:
            return len(stdout.strip()) == 0
        return False
    
    def stash_local_changes(self) -> bool:
        """Stash local changes"""
        if not self.is_repo_clean():
            self.logger.info("Stashing local changes...")
            success, stdout, stderr = self.run_git_command(['git', 'stash', 'push', '-m', f'AutoDR stash {datetime.now().isoformat()}'])
            if success:
                self.logger.info("Local changes stashed successfully")
                return True
            else:
                self.logger.error(f"Failed to stash changes: {stderr}")
                return False
        return True
    
    def ensure_correct_branch(self) -> bool:
        """Ensure we're on the correct branch"""
        target_branch = self.config.get('repository', 'branch')
        current_branch = self.get_current_branch()
        
        if current_branch != target_branch:
            self.logger.info(f"Switching from '{current_branch}' to '{target_branch}'")
            
            # Stash changes if needed
            if not self.is_repo_clean() and self.config.getboolean('options', 'auto_stash', fallback=True):
                if not self.stash_local_changes():
                    return False
            
            # Switch branch
            success, stdout, stderr = self.run_git_command(['git', 'checkout', target_branch])
            if not success:
                self.logger.error(f"Failed to checkout branch '{target_branch}': {stderr}")
                return False
                
        return True
    
    def fetch_remote_changes(self) -> bool:
        """Fetch changes from remote"""
        self.logger.info("Fetching remote changes...")
        success, stdout, stderr = self.run_git_command(['git', 'fetch', 'origin'])
        if success:
            self.logger.info("Remote changes fetched successfully")
            return True
        else:
            self.logger.error(f"Failed to fetch remote changes: {stderr}")
            return False
    
    def pull_latest_changes(self) -> bool:
        """Pull latest changes from remote"""
        branch = self.config.get('repository', 'branch')
        self.logger.info(f"Pulling latest changes for branch '{branch}'...")
        
        success, stdout, stderr = self.run_git_command(['git', 'pull', 'origin', branch])
        if success:
            self.logger.info("Successfully pulled latest changes")
            self.logger.info(f"Pull output: {stdout}")
            return True
        else:
            self.logger.error(f"Failed to pull changes: {stderr}")
            return False
    
    def is_behind_remote(self) -> bool:
        """Check if local branch is behind remote"""
        branch = self.config.get('repository', 'branch')
        
        # Get commit counts
        success, stdout, stderr = self.run_git_command([
            'git', 'rev-list', '--count', f'HEAD..origin/{branch}'
        ])
        
        if success:
            behind_count = int(stdout.strip())
            return behind_count > 0
        else:
            self.logger.warning(f"Could not determine if behind remote: {stderr}")
            return True  # Assume we need to pull to be safe
    
    def initialize_repository(self) -> bool:
        """Initialize repository if it doesn't exist"""
        local_path = self.config.get('repository', 'local_path')
        repo_url = self.config.get('repository', 'url')
        
        if not os.path.exists(os.path.join(local_path, '.git')):
            self.logger.info(f"Initializing repository from {repo_url}")
            
            # Create directory if it doesn't exist
            os.makedirs(local_path, exist_ok=True)
            
            success, stdout, stderr = self.run_git_command(['git', 'clone', repo_url, '.'], cwd=local_path)
            if success:
                self.logger.info("Repository cloned successfully")
                return True
            else:
                self.logger.error(f"Failed to clone repository: {stderr}")
                return False
        return True
    
    def sync_repository(self) -> bool:
        """Main synchronization logic"""
        self.logger.info("Starting repository synchronization...")
        
        # Initialize repository if needed
        if not self.initialize_repository():
            return False
        
        # Fetch remote changes
        if not self.fetch_remote_changes():
            return False
        
        # Ensure we're on the correct branch
        if not self.ensure_correct_branch():
            return False
        
        # Check if we need to pull
        force_pull = self.config.getboolean('options', 'force_pull', fallback=False)
        
        if force_pull or self.is_behind_remote():
            # Get commit hashes for comparison
            local_hash = self.get_local_commit_hash()
            remote_hash = self.get_remote_commit_hash()
            
            self.logger.info(f"Local commit:  {local_hash}")
            self.logger.info(f"Remote commit: {remote_hash}")
            
            if local_hash != remote_hash or force_pull:
                # Handle local changes
                if not self.is_repo_clean():
                    if self.config.getboolean('options', 'auto_stash', fallback=True):
                        if not self.stash_local_changes():
                            return False
                    else:
                        self.logger.error("Working directory is not clean. Use --force or enable auto_stash")
                        return False
                
                # Pull latest changes
                if not self.pull_latest_changes():
                    return False
                    
                self.logger.info("Repository synchronized successfully!")
                return True
            else:
                self.logger.info("Repository is already up to date")
                return True
        else:
            self.logger.info("No remote changes detected")
            return True

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Automatic Repository Synchronization Tool',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # Use default config.ini
  %(prog)s --config my_config.ini    # Use custom config
  %(prog)s --force                   # Force pull regardless of changes
  %(prog)s --dry-run                 # Show what would be done
  %(prog)s --init-config             # Create sample config file
        """
    )
    
    parser.add_argument('--config', '-c', default='config.ini',
                       help='Configuration file path (default: config.ini)')
    parser.add_argument('--force', '-f', action='store_true',
                       help='Force pull regardless of local state')
    parser.add_argument('--dry-run', '-n', action='store_true',
                       help='Show what would be done without executing')
    parser.add_argument('--init-config', action='store_true',
                       help='Create a sample configuration file and exit')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.init_config:
        # Create sample config and exit
        sync_manager = AutoRepoSync(args.config)
        print(f"Sample configuration created at: {args.config}")
        print("Please edit the configuration file with your repository details.")
        return 0
    
    try:
        # Create sync manager
        sync_manager = AutoRepoSync(args.config)
        
        # Override config options with command line args
        if args.force:
            sync_manager.config.set('options', 'force_pull', 'true')
        
        if args.verbose:
            sync_manager.config.set('logging', 'level', 'DEBUG')
            sync_manager.logger.setLevel(logging.DEBUG)
        
        if args.dry_run:
            sync_manager.logger.info("DRY RUN MODE - No changes will be made")
            # In a real implementation, you'd add dry-run logic here
            return 0
        
        # Run synchronization
        success = sync_manager.sync_repository()
        
        if success:
            sync_manager.logger.info("Synchronization completed successfully")
            return 0
        else:
            sync_manager.logger.error("Synchronization failed")
            return 1
            
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        return 130
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())