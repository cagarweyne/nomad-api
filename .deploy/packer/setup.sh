#!/bin/bash

# tell bash to print out the statements as they are being executed so that we can see them running
set -x

# Install necessary dependencies - install docker - first run update - comments
sudo apt-get update -y 
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Use the following command to set up the stable repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# install docker 
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# verify the installation by running hello-world image as container
sudo docker run hello-world
# login to docker and pull down image
sudo docker login --username $USERNAME --password $PASSWORD
sudo docker pull cagarweyne/nomad  

