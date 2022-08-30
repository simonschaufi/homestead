#!/usr/bin/env bash

# Check If Influxdb Has Been Installed

if [[ -f /home/vagrant/.influxdb ]]
then
    echo "InfluxDB already installed."
    exit 0
fi

touch /home/vagrant/.influxdb

sudo apt-get update
sudo apt-get install -y influxdb
sudo apt-get install -y influxdb-client
