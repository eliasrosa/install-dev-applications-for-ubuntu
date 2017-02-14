#!/usr/bin/env bash

echo "Updating System.."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Install Sublime Text"
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install sublime-text-installer

echo "Install Commons Applications "
sudo apt-get install filezilla
sudo apt-get install ark
sudo apt-get install teamviewer
sudo apt-get install google-chrome-stable


wget http://dbeaver.jkiss.org/files/dbeaver-ce_latest_amd64.deb
sudo dpkg -i dbeaver-ce_latest_amd64.deb
rm -f dbeaver-ce_latest_amd64.deb
