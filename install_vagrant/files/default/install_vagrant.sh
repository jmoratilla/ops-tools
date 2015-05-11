#!/bin/bash

echo "Instalando knife..."
[ ! -f chefdk_0.3.2-1_amd64.deb ] && wget http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.2-1_amd64.deb
sudo dpkg --install chefdk_0.3.2-1_amd64.deb
[ ! -f ~/.using-chef-dk ] && sudo chef shell-init bash >> ~/.bashrc && touch ~/.using-chef-dk

echo "Instalando ruby..."
sudo apt-get install -y python-software-properties software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get -y update
sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libssl-dev

echo "Instalando Vagrant..."
[ ! -f vagrant_1.6.3_x86_64.deb ] && wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
sudo dpkg --install vagrant_1.6.3_x86_64.deb


echo "Instalando plugins de vagrant..."

vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-aws
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-butcher
vagrant plugin install vagrant-shell-commander
vagrant plugin install vagrant-proxyconf

echo "Instalando berkshelf..."
sudo gem install berkshelf
echo "{\"ssl\":{\"verify\": false }}" > ~/.berkshelf/config.json

echo "Instalando virtualbox"
sudo apt-get install -y virtualbox virtualbox-guest*
