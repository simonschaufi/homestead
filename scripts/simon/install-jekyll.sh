#!/usr/bin/env bash

if [[ -f /home/vagrant/.jekyll ]]
then
    echo "Jekyll already installed."
    exit 0
fi
touch /home/vagrant/.jekyll

# https://jekyllrb.com/docs/installation/ubuntu/
sudo apt install -y ruby ruby-dev build-essential

echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME=$HOME/gems' >> ~/.bashrc
echo 'export PATH=$HOME/gems/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

gem install jekyll bundler

# open jekyll port 4000
sudo iptables -I INPUT -p tcp --dport 4000 -j ACCEPT
sudo iptables-save
