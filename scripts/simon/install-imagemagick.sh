#!/usr/bin/env bash

if [[ -f /home/vagrant/.imagemagick ]]
then
    echo "Imagemagick already installed."
    exit 0
fi
touch /home/vagrant/.imagemagick

sudo apt-get update

sudo apt-get install -y imagemagick php-imagick
