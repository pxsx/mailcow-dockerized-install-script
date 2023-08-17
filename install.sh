#!/bin/bash

# This script is for installing mailcow-dockerized on Debian 11 in /opt/mailcow-dockerized

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Ask the user for the domain name
read -p "Enter the domain name for your Mailcow installation: " MAILCOW_DOMAIN

# Update and upgrade packages
apt update && apt upgrade -y

# Install required dependencies
apt install -y curl git apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Clone the mailcow repository into /opt
git clone https://github.com/mailcow/mailcow-dockerized /opt/mailcow-dockerized
cd /opt/mailcow-dockerized

# Generate configuration
./generate_config.sh

# Update mailcow.conf with the provided domain name
sed -i "s/^MAILCOW_HOSTNAME=.*$/MAILCOW_HOSTNAME=$MAILCOW_DOMAIN/g" mailcow.conf

# Bring up mailcow
docker-compose pull
docker-compose up -d

# Output completion message
echo "Mailcow installation in /opt/mailcow-dockerized is completed. Please navigate to https://$MAILCOW_DOMAIN to access the Mailcow UI."
