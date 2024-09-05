GREEN='\033[0;32m'  # Green text for success messages
RED='\033[0;31m'   # Red text for error messages
NC='\033[0m'        # Reset color

# Check for lsb_release command and warn if not found
if ! command -v lsb_release >/dev/null 2>&1; then
  echo -e "${RED}lsb_release not found. Script may not work on all systems.${NC}"
  exit 1  # Indicate failure with exit code 1
fi

# Get the distribution name and version using lsb_release
DISTRO=$(lsb_release -is)

echo -e "This is a ${DISTRO} distribution"

# Install Docker dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

if [ "$DISTRO" = "Ubuntu" ]; then
    echo -e "${GREEN}This is an Ubuntu system.${NC}"
    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable"
elif [ "$DISTRO" = "Debian" ]; then
    echo -e "${GREEN}This is a Debian system.${NC}"
    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable"
else
  echo -e "${RED}Unsupported distribution: $DISTRO.${NC}"
  exit 1  # Indicate failure with exit code 1
fi


apt-cache policy docker-ce

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker ${USER}


sudo systemctl enable docker

sudo systemctl start docker

sudo systemctl status --no-pager docker

