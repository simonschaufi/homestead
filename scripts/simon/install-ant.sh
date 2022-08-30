#!/usr/bin/env bash

if [[ -f /home/vagrant/.ant ]]
then
    echo "Ant already installed."
    exit 0
fi
touch /home/vagrant/.ant

sudo apt update

sudo apt install -y openjdk-8-jdk
sudo apt install -y ant
