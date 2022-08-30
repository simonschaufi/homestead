#!/usr/bin/env bash

if [[ -f /home/vagrant/.pngquant ]]
then
    echo "pngquant already installed."
    exit 0
fi
touch /home/vagrant/.pngquant

sudo apt update

sudo apt install -y pngquant
