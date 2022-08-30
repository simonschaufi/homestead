#!/usr/bin/env bash

if [[ -f /home/vagrant/.graylog2 ]]
then
    echo "Graylog already installed."
    exit 0
fi
touch /home/vagrant/.graylog2

# Prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen

# ---

# @see https://www.alibabacloud.com/blog/how-to-install-graylog-on-ubuntu-16-04_594046

# Before we actually install Graylog, we need to install Elastic Search
# @see https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

#sudo apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

sudo apt-get update && sudo apt-get install -y elasticsearch

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service



# finally install Graylog

sudo apt-get install -y apt-transport-https
cd /tmp
wget https://packages.graylog2.org/repo/packages/graylog-2.4-repository_latest.deb
sudo dpkg -i graylog-2.4-repository_latest.deb
sudo apt-get update
sudo apt-get install -y graylog-server

# post setup
sudo apt install -y pwgen

password_secret=`pwgen -N 1 -s 96`
sudo sed -i "s/password_secret =/password_secret = ${password_secret}/g" /etc/graylog/server/server.conf

root_password_sha2=`echo -n secret | shasum -a 256 | cut -d" " -f1`
# Interaktiv
#root_password_sha2=`echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1`
sudo sed -i "s/root_password_sha2 =/root_password_sha2 = ${root_password_sha2}/g" /etc/graylog/server/server.conf


# start Graylog automatically on system boot
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
