#!/usr/bin/env bash

if [[ -f /home/vagrant/.ab ]]
then
    echo "ApacheBench already installed."
    exit 0
fi
touch /home/vagrant/.ab

sudo apt update

sudo apt install -y apache2-utils
