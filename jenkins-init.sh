#! /bin/bash

# Jenkins Repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# install dependencies
apt-get update
apt-get install -y openjdk-8-jre

# install Jenkins
apt-get install -y jenkins

# clean up
apt-get clean
