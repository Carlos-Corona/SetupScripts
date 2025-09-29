# AutoDR - Automatic Repository Synchronization

An improved Python script for automatically synchronizing local repositories with remote Git repositories. Designed for periodic execution via cron jobs or manual runs.

## Features

- 🔄 **Smart Synchronization**: Only pulls when remote has new commits
- 🌿 **Branch Management**: Ensures you're on the correct branch before syncing
- 🔒 **Safe Operations**: Automatically stashes local changes to prevent conflicts
- 📊 **Comprehensive Logging**: Detailed logs for monitoring and debugging
- ⚙️ **Configurable**: Easy configuration via INI files
- 🚀 **Cron-Ready**: Perfect for automated scheduled runs
- 🛡️ **Error Handling**: Robust error handling and recovery
- 📋 **Multiple Modes**: Support for dry-run, verbose, and force modes

## Installation

1. **Clone or download the script**:
   ```bash
   wget https://raw.githubusercontent.com/your-repo/AutoDR.py
   chmod +x AutoDR.py
   ```

2. **Install required dependencies**:
   ```bash
   pip3 install requests configparser
   ```

3. **Create configuration file**:
   ```bash
   python3 AutoDR.py --init-config
   ```

4. **Edit the configuration**:
   ```bash
   nano config.ini
   ```

## Configuration

Edit `config.ini` with your repository details:

```ini
[repository]
url = https://github.com/your_username/your_repository.git
branch = main
local_path = /path/to/your/local/repo
token = your_github_token_here

[logging]
level = INFO
file = auto_repo_sync.log

[options]
force_pull = false
backup_local_changes = true
auto_stash = true
```

### GitHub Token Setup

For private repositories or to avoid rate limits:

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (for private repos) or `public_repo` (for public repos)
4. Copy the token to your config file

## Usage

### Basic Usage

```bash
# Run with default config.ini
python3 AutoDR.py

# Use custom config file
python3 AutoDR.py --config my_repo_config.ini

# Force synchronization regardless of changes
python3 AutoDR.py --force

# Dry run (see what would happen without making changes)
python3 AutoDR.py --dry-run

# Verbose output for debugging
python3 AutoDR.py --verbose
```

### Command Line Options

- `--config, -c`: Specify configuration file (default: config.ini)
- `--force, -f`: Force pull regardless of local state
- `--dry-run, -n`: Show what would be done without executing
- `--init-config`: Create a sample configuration file
- `--verbose, -v`: Enable verbose logging

## Cron Job Setup

To run automatically every 15 minutes:

1. **Open crontab**:
   ```bash
   crontab -e
   ```

2. **Add entry**:
   ```bash
   # Sync repository every 15 minutes
   */15 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/config.ini >> /var/log/auto_repo_sync_cron.log 2>&1
   
   # Or for hourly sync
   0 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/config.ini
   ```

3. **Multiple repositories**:
   ```bash
   # Project 1 - every 15 minutes
   */15 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/project1_config.ini
   
   # Project 2 - every hour
   0 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/project2_config.ini
   
   # Critical project - every 5 minutes
   */5 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/critical_config.ini
   ```

## Systemd Service (Alternative to Cron)

Create a systemd service for more advanced scheduling:

1. **Create service file**:
   ```bash
   sudo nano /etc/systemd/system/auto-repo-sync@.service
   ```

   ```ini
   [Unit]
   Description=Auto Repository Sync for %i
   After=network.target

   [Service]
   Type=oneshot
   User=your_username
   WorkingDirectory=/path/to/script
   ExecStart=/usr/bin/python3 /path/to/AutoDR.py --config /path/to/configs/%i.ini
   ```

2. **Create timer file**:
   ```bash
   sudo nano /etc/systemd/system/auto-repo-sync@.timer
   ```

   ```ini
   [Unit]
   Description=Run Auto Repository Sync for %i every 15 minutes
   Requires=auto-repo-sync@%i.service

   [Timer]
   OnCalendar=*:0/15
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

3. **Enable and start**:
   ```bash
   sudo systemctl enable auto-repo-sync@myproject.timer
   sudo systemctl start auto-repo-sync@myproject.timer
   ```

## How It Works

1. **Initialization**: Checks if local repository exists, clones if needed
2. **Remote Check**: Fetches latest information from remote repository
3. **Branch Verification**: Ensures you're on the correct branch
4. **Change Detection**: Compares local and remote commit hashes
5. **Safe Sync**: Stashes local changes if needed, then pulls updates
6. **Logging**: Records all operations with timestamps

## Error Handling

The script handles various scenarios:

- **Network issues**: Graceful timeout and retry
- **Authentication problems**: Clear error messages for token issues
- **Local changes**: Automatic stashing with backup
- **Branch conflicts**: Automatic branch switching
- **Merge conflicts**: Detailed error reporting
- **Repository corruption**: Initialization recovery

## Logging

Logs are written to both console and file (if configured):

```
2025-09-29 10:15:30 - AutoDR - INFO - Starting repository synchronization...
2025-09-29 10:15:31 - AutoDR - INFO - Fetching remote changes...
2025-09-29 10:15:32 - AutoDR - INFO - Remote changes fetched successfully
2025-09-29 10:15:32 - AutoDR - INFO - Local commit:  abc123def456...
2025-09-29 10:15:32 - AutoDR - INFO - Remote commit: def456abc123...
2025-09-29 10:15:33 - AutoDR - INFO - Pulling latest changes for branch 'main'...
2025-09-29 10:15:34 - AutoDR - INFO - Successfully pulled latest changes
2025-09-29 10:15:34 - AutoDR - INFO - Repository synchronized successfully!
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**:
   - Check your GitHub token in config.ini
   - Ensure token has correct permissions

2. **Repository Not Found**:
   - Verify repository URL in config.ini
   - Check if repository is private and token is provided

3. **Local Changes Conflict**:
   - Enable `auto_stash = true` in config
   - Or use `--force` flag

4. **Permission Denied**:
   - Check file permissions: `chmod +x AutoDR.py`
   - Ensure user has write access to local_path

5. **Network Timeout**:
   - Check internet connection
   - Repository might be temporarily unavailable

### Debug Mode

Run with verbose flag for detailed information:

```bash
python3 AutoDR.py --verbose
```

## Security Considerations

- Store GitHub tokens securely
- Use appropriate file permissions for config files: `chmod 600 config.ini`
- Consider using SSH keys instead of tokens for authentication
- Regularly rotate access tokens

## Contributing

Improvements and suggestions are welcome! Please ensure:
- Code follows Python PEP 8 standards
- Add appropriate logging for new features
- Test with various Git scenarios
- Update documentation for new options

## License

MIT License - Feel free to use and modify as needed.