#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PATH_APACHE="/home/${USER}/www"

PHP_INI=(
	"short_open_tag=On"
	"display_error=On"
	"display_startup_errors=On"
	"error_reporting=E_ALL \\\\& ~E_NOTICE \\\\& ~E_DEPRECATED \\\\& ~E_STRICT"
)

VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "${PATH_APACHE}"

    ErrorLog ${PATH_APACHE}/.logs/error.log
    CustomLog ${PATH_APACHE}/.logs/access.log combined

    <ifmodule mpm_itk_module>
        AssignUserID ${USER} ${USER}
    </ifmodule>

    <Directory "${PATH_APACHE}">
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule dir_module>
        DirectoryIndex index.php index.html index.xhtml index.htm
    </IfModule>
</VirtualHost>
EOF
)

PHPINFO=$(cat <<EOF
<?php

phpinfo();

EOF
)


# stop services
# ---------------------------------
sudo service apache2 stop
sudo service mysql stop


# update / upgrade
# ---------------------------------
sudo apt-get update
sudo apt-get -y upgrade


# install mysql and give password to installer
# ---------------------------------
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"


# install apache 2 and php 5
# ---------------------------------
sudo apt-get install -y apache2
sudo apt-get install -y apache2-mpm-itk
sudo apt-get install -y apache2-mpm-prefork
sudo apt-get install -y libapache2-mod-php5
sudo apt-get install -y php5
sudo apt-get install -y php5-curl
sudo apt-get install -y php5-gd
sudo apt-get install -y git
sudo apt-get install -y mysql-server
sudo apt-get install -y php5-mysql
sudo apt-get install -y build-essential
sudo apt-get install -y php-pear
sudo apt-get install -y php5-dev
sudo apt-get install -y sendmail


# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
# ---------------------------------
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin


# Apache changes
# ---------------------------------
sudo mkdir ${PATH_APACHE}
sudo mkdir ${PATH_APACHE}/.logs
sudo echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf
sudo echo "${PHPINFO}" > ${PATH_APACHE}/index.php
sudo echo "ServerName localhost" >> /etc/apache2/apache2.conf
sudo a2dismod mpm_prefork
sudo a2enmod mpm_itk
sudo a2enmod rewrite


# Configure MySQL database and user
# ---------------------------------
echo "FLUSH PRIVILEGES" | mysql -uroot -proot


# Install Composer
# ---------------------------------
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
composer self-update


# Configure php.ini
# ---------------------------------
for ix in ${!PHP_INI[*]}
do
	IFS="=" read var val <<< ${PHP_INI[$ix]}
	PHP_CONF="$var = $val"
	sudo sed -i "s#^$var.*#$PHP_CONF#" /etc/php5/apache2/php.ini
	echo "Set php.ini >>>> $var = $val"
done


# Install Mailcatcher
# ---------------------------------
#echo "Installing mailcatcher"
#sudo apt-get install -y ruby2.0-dev
#sudo apt-get install -y libsqlite3-dev
#sudo gem install mime-types --version "< 3"
#sudo gem install mailcatcher --conservative
#sudo gem install mailcatcher --no-ri --no-rdoc
# sed -i '/;sendmail_path =/c sendmail_path = "/usr/local/bin/catchmail"' /etc/php5/apache2/php.ini


# Limpa os arquivos de Log
# ---------------------------------
echo "Truncate error.log and access.log"
sudo truncate -s 0 ${PATH_APACHE}/.logs/error.log
sudo truncate -s 0 ${PATH_APACHE}/.logs/access.log


# Restart services
# ---------------------------------
sudo ./restart-services.sh

