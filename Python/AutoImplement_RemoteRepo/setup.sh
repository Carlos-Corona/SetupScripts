#!/bin/bash

# AutoDR Setup Script
# This script helps set up AutoDR for automatic repository synchronization

set -e

echo "🚀 AutoDR - Automatic Repository Synchronization Setup"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Python 3 is installed
check_python() {
    print_header "Checking Python installation..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_status "Python 3 found: $PYTHON_VERSION"
    else
        print_error "Python 3 is not installed. Please install Python 3 first."
        exit 1
    fi
}

# Check if pip is available
check_pip() {
    print_header "Checking pip installation..."
    
    if command -v pip3 &> /dev/null; then
        print_status "pip3 found"
    elif command -v pip &> /dev/null; then
        print_status "pip found"
        alias pip3=pip
    else
        print_error "pip is not installed. Installing pip..."
        python3 -m ensurepip --upgrade
    fi
}

# Install required Python packages
install_dependencies() {
    print_header "Installing Python dependencies..."
    
    print_status "Installing requests..."
    python3 -m pip install requests --user
    
    print_status "Dependencies installed successfully"
}

# Make script executable
make_executable() {
    print_header "Making AutoDR executable..."
    chmod +x AutoDR.py
    print_status "AutoDR.py is now executable"
}

# Create configuration file
create_config() {
    print_header "Creating configuration file..."
    
    if [ ! -f "config.ini" ]; then
        python3 AutoDR.py --init-config
        print_status "Configuration file created: config.ini"
        print_warning "Please edit config.ini with your repository details"
    else
        print_warning "config.ini already exists. Skipping creation."
    fi
}

# Interactive configuration setup
interactive_config() {
    print_header "Interactive Configuration Setup"
    
    read -p "Do you want to configure the repository settings interactively? [y/N]: " configure_now
    
    if [[ $configure_now =~ ^[Yy]$ ]]; then
        echo
        print_status "Let's configure your repository settings..."
        
        # Get repository URL
        read -p "Enter your repository URL (e.g., https://github.com/user/repo.git): " repo_url
        
        # Get branch name
        read -p "Enter the branch name [main]: " branch_name
        branch_name=${branch_name:-main}
        
        # Get local path
        read -p "Enter local repository path [current directory]: " local_path
        local_path=${local_path:-.}
        
        # Get GitHub token
        echo
        print_warning "GitHub token is optional but recommended for private repos and higher rate limits"
        print_warning "Generate at: https://github.com/settings/tokens"
        read -p "Enter your GitHub personal access token (optional): " github_token
        
        # Update config file
        cat > config.ini << EOF
[repository]
url = $repo_url
branch = $branch_name
local_path = $local_path
token = $github_token

[logging]
level = INFO
file = auto_repo_sync.log

[options]
force_pull = false
backup_local_changes = true
auto_stash = true
EOF
        
        print_status "Configuration updated successfully!"
    else
        print_warning "Please edit config.ini manually before running AutoDR"
    fi
}

# Setup cron job
setup_cron() {
    print_header "Cron Job Setup"
    
    read -p "Do you want to set up a cron job for automatic synchronization? [y/N]: " setup_cron_job
    
    if [[ $setup_cron_job =~ ^[Yy]$ ]]; then
        echo
        print_status "Setting up cron job..."
        
        # Get current script path
        SCRIPT_PATH=$(readlink -f AutoDR.py)
        CONFIG_PATH=$(readlink -f config.ini)
        
        echo "Available intervals:"
        echo "1) Every 15 minutes"
        echo "2) Every 30 minutes" 
        echo "3) Every hour"
        echo "4) Every 2 hours"
        echo "5) Custom"
        
        read -p "Select interval [1]: " interval_choice
        interval_choice=${interval_choice:-1}
        
        case $interval_choice in
            1) CRON_SCHEDULE="*/15 * * * *" ;;
            2) CRON_SCHEDULE="*/30 * * * *" ;;
            3) CRON_SCHEDULE="0 * * * *" ;;
            4) CRON_SCHEDULE="0 */2 * * *" ;;
            5) 
                read -p "Enter custom cron schedule (e.g., '0 */6 * * *' for every 6 hours): " CRON_SCHEDULE
                ;;
            *) 
                print_warning "Invalid choice, using every 15 minutes"
                CRON_SCHEDULE="*/15 * * * *"
                ;;
        esac
        
        # Create cron entry
        CRON_ENTRY="$CRON_SCHEDULE /usr/bin/python3 $SCRIPT_PATH --config $CONFIG_PATH >> /tmp/auto_repo_sync.log 2>&1"
        
        # Add to crontab
        (crontab -l 2>/dev/null || true; echo "$CRON_ENTRY") | crontab -
        
        print_status "Cron job added successfully!"
        print_status "Schedule: $CRON_SCHEDULE"
        print_status "Logs will be written to: /tmp/auto_repo_sync.log"
        
        echo
        print_warning "You can view/edit cron jobs with: crontab -e"
        print_warning "You can view cron logs with: tail -f /tmp/auto_repo_sync.log"
    fi
}

# Test the configuration
test_configuration() {
    print_header "Testing Configuration"
    
    read -p "Do you want to test the configuration with a dry run? [Y/n]: " test_config
    
    if [[ ! $test_config =~ ^[Nn]$ ]]; then
        echo
        print_status "Running dry-run test..."
        
        if python3 AutoDR.py --dry-run --verbose; then
            print_status "Configuration test completed successfully!"
        else
            print_error "Configuration test failed. Please check your settings."
            return 1
        fi
    fi
}

# Main setup function
main() {
    echo
    print_status "Starting AutoDR setup..."
    echo
    
    check_python
    check_pip
    install_dependencies
    make_executable
    create_config
    
    echo
    interactive_config
    
    echo
    setup_cron
    
    echo
    test_configuration
    
    echo
    print_header "Setup Complete! 🎉"
    echo
    print_status "AutoDR has been set up successfully!"
    echo
    echo "Next steps:"
    echo "1. Edit config.ini if you haven't already"
    echo "2. Test manually: python3 AutoDR.py --verbose"
    echo "3. Check cron logs: tail -f /tmp/auto_repo_sync.log"
    echo
    echo "For more information, see README.md"
}

# Run main function
main "$@"