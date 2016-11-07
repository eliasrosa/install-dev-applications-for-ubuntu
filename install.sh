#!/usr/bin/env bash

echo "Updating System.."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing Apache2"
sudo apt-get install -y apache2
sudo apt-get install -y apache2-doc
sudo apt-get install -y apache2-utils
sudo apt-get install -y libexpat1
sudo apt-get install -y ssl-cert

echo "Installing PHP & Requirements"
sudo apt-get install -y php7.0
sudo apt-get install -y php-pear
sudo apt-get install -y php7.0-common
sudo apt-get install -y php7.0-curl
sudo apt-get install -y php7.0-dev
sudo apt-get install -y php7.0-gd
sudo apt-get install -y php7.0-mcrypt
sudo apt-get install -y php7.0-mbstring
sudo apt-get install -y php7.0-mysql
sudo apt-get install -y php7.0-json
sudo apt-get install -y php7.0-zip
sudo apt-get install -y php7.0-xsl
sudo apt-get install -y php7.0-xml
sudo apt-get install -y php7.0-xmlrpc
sudo apt-get install -y libapache2-mod-php7.0

echo "Installing MySQL"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install -y mysql-server 
sudo apt-get install -y mysql-client
sudo apt-get install -y libmysqlclient15.dev

echo "Installing phpMyAdmin"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get install -y phpmyadmin
 
echo "Installing Composer & Git"
sudo apt-get install -y composer
sudo apt-get install -y git
sudo apt-get install -y gitg

echo "Permissions for /var/www"
sudo usermod -aG www-data ${SUDO_USER}
sudo chown -R ${SUDO_USER}:www-data /var/www/html
ln -s /var/www/html /home/${SUDO_USER}/www

echo "Enabling Modules"
sudo a2enmod rewrite
sudo a2enmod php7.0

echo "Restarting Apache"
sudo service apache2 restart
sudo service mysql restart
