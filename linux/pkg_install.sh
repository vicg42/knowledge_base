#!/bin/bash

read -p "Enter password for root user: " PASS
echo ""

echo "Checking installed pakages"

#sudo add-apt-repository ppa:cran/opencv-4.2
sudo apt update

for arg in openssh-server \
unzip mc tmux wget snapd minicom \
git build-essential cmake \
libjpeg-dev libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran \
libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa \
gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio \
python3-venv python3-pip python-pip \
libopencv-dev
do
    dpkg -s $arg &> /dev/null
    if [[ ! $? -eq 0 ]]; then
        echo $PASS | sudo -S apt-get install -y $arg
    fi
done

#Настройки:

##SSH
#systemctl enable ssh
#systemctl start ssh

##Python
#version2.x
#python -m pip install numpy
#python -m pip install opencv-python
#
#version3.x
#pip3 install --upgrade setuptools
#pip3 install --upgrade pip
#python3 -m pip install numpy
#python3 -m pip install opencv-python

##Nomachine
#https://www.nomachine.com/ru/download/download&id=1
#sudo dpkg -i nomachine_7.4.1_1_amd64.deb

##GIT config
##git config --global user.name "v.golovachenko"
##git config --global user.email "v.golovachenko@sparklab.by"
## mc -e ~/.gitconfig
#[alias]
#	logg = log --pretty=format:\"%h %ad [%cn] | %s%d \" --date=short --graph --stat --decorate=short
#	ls = log --pretty=format:\"%h %ad [%cn] | %s%d \" --date=short --graph --stat --decorate=short

#Drawio
#sudo snap install drawio
