#!/usr/bin/env bash

if [[ -f /home/vagrant/.docker-io ]]
then
    echo "docker already installed."
    exit 0
fi
touch /home/vagrant/.docker-io

sudo apt update

# @see https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
# @see https://linuxconfig.org/how-to-install-docker-on-ubuntu-18-04-bionic-beaver
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker vagrant

# Install docker-compose (@see https://docs.docker.com/compose/install/)
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install command completion https://docs.docker.com/compose/completion/#bash
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.25.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
