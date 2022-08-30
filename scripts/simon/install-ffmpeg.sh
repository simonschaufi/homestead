#!/usr/bin/env bash

if [[ -f /home/vagrant/.ffmpeg ]]
then
    echo "ffmpeg already installed."
    exit 0
fi
touch /home/vagrant/.ffmpeg

sudo apt update

sudo apt install -y ffmpeg libavcodec-extra
