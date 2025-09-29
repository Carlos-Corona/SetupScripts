#!/bin/bash

# AutoDR Usage Examples
# This file contains practical examples of how to use AutoDR

echo "AutoDR - Automatic Repository Synchronization Examples"
echo "===================================================="

# Example 1: Basic usage with default config
echo
echo "1. Basic usage (uses config.ini in current directory):"
echo "   python3 AutoDR.py"

# Example 2: Custom config file
echo
echo "2. Using custom configuration file:"
echo "   python3 AutoDR.py --config /path/to/my_project_config.ini"

# Example 3: Force synchronization
echo
echo "3. Force pull regardless of changes:"
echo "   python3 AutoDR.py --force"

# Example 4: Dry run to see what would happen
echo
echo "4. Dry run (test without making changes):"
echo "   python3 AutoDR.py --dry-run"

# Example 5: Verbose output for debugging
echo
echo "5. Verbose mode for debugging:"
echo "   python3 AutoDR.py --verbose"

# Example 6: Initialize new config
echo
echo "6. Create new configuration file:"
echo "   python3 AutoDR.py --init-config"

# Example 7: Multiple repositories with different configs
echo
echo "7. Multiple repositories (different terminals/cron jobs):"
echo "   python3 AutoDR.py --config ~/configs/project1.ini"
echo "   python3 AutoDR.py --config ~/configs/project2.ini"
echo "   python3 AutoDR.py --config ~/configs/project3.ini"

echo
echo "Cron Job Examples:"
echo "=================="

# Example cron jobs
echo
echo "1. Every 15 minutes:"
echo "   */15 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/config.ini"

echo
echo "2. Every hour:"
echo "   0 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/config.ini"

echo
echo "3. Every 6 hours:"
echo "   0 */6 * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/config.ini"

echo
echo "4. Daily at 2 AM:"
echo "   0 2 * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/config.ini"

echo
echo "5. Multiple repositories with different schedules:"
echo "   # Critical project - every 5 minutes"
echo "   */5 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/critical.ini"
echo "   # Main project - every 15 minutes" 
echo "   */15 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/main.ini"
echo "   # Backup project - hourly"
echo "   0 * * * * /usr/bin/python3 /path/to/AutoDR.py --config /path/to/backup.ini"

echo
echo "Systemd Timer Examples:"
echo "======================"

echo
echo "1. Enable systemd timer for a project:"
echo "   sudo systemctl enable auto-repo-sync@myproject.timer"
echo "   sudo systemctl start auto-repo-sync@myproject.timer"

echo
echo "2. Check timer status:"
echo "   sudo systemctl status auto-repo-sync@myproject.timer"

echo
echo "3. View logs:"
echo "   sudo journalctl -u auto-repo-sync@myproject.service -f"

echo
echo "Configuration Examples:"
echo "======================"

cat << 'EOF'

Example config.ini for a public repository:
-------------------------------------------
[repository]
url = https://github.com/user/public-repo.git
branch = main
local_path = /home/user/repos/public-repo
token = 

[logging]
level = INFO
file = sync.log

[options]
force_pull = false
backup_local_changes = true
auto_stash = true

Example config.ini for a private repository:
--------------------------------------------
[repository]
url = https://github.com/user/private-repo.git
branch = develop
local_path = /home/user/repos/private-repo
token = ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

[logging]
level = DEBUG
file = /var/log/private-repo-sync.log

[options]
force_pull = false
backup_local_changes = true
auto_stash = true

Example config.ini for a work project:
-------------------------------------
[repository]
url = https://github.com/company/work-project.git
branch = main
local_path = /opt/projects/work-project
token = ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

[logging]
level = WARNING
file = /var/log/work-project-sync.log

[options]
force_pull = true
backup_local_changes = true
auto_stash = true
EOF

echo
echo "Troubleshooting Examples:"
echo "========================"

echo
echo "1. Test configuration:"
echo "   python3 AutoDR.py --dry-run --verbose"

echo
echo "2. Check if repository is accessible:"
echo "   git ls-remote https://github.com/user/repo.git"

echo
echo "3. Verify GitHub token:"
echo "   curl -H \"Authorization: token YOUR_TOKEN\" https://api.github.com/user"

echo
echo "4. Manual git operations for comparison:"
echo "   git fetch origin"
echo "   git status"
echo "   git log --oneline -5"

echo
echo "5. Check cron job logs:"
echo "   tail -f /tmp/auto_repo_sync.log"
echo "   grep AutoDR /var/log/syslog"

echo
echo "For more information, see README.md"