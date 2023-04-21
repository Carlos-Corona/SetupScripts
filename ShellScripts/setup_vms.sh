#!/bin/bash

# Update apt cache
sudo apt update

# Upgrade system packages
sudo apt upgrade -y

# Install Python
sudo apt install -y python3

# Install MariaDB
sudo apt install -y mariadb-server

# Install Nginx
sudo apt install -y nginx

# Install Docker dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

# Update apt cache again
sudo apt update

# Install Docker
sudo apt install -y docker-ce

# Install Docker Compose
sudo apt install -y docker-compose

sudo apt install -y ifconfig