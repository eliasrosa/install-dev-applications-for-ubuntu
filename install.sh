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
sudo apt-get install -y git-gui

echo "Enabling Modules"
sudo a2enmod rewrite
sudo a2enmod php7.0

echo "Configurating PHP"
PHP_INI=(
	"short_open_tag=On"
	"display_error=On"
	"display_startup_errors=On"
	"error_reporting=E_ALL \\\\& ~E_NOTICE \\\\& ~E_DEPRECATED \\\\& ~E_STRICT"
)
for ix in ${!PHP_INI[*]}
do
	IFS="=" read var val <<< ${PHP_INI[$ix]}
	PHP_CONF="$var = $val"
	sudo sed -i "s#^$var.*#$PHP_CONF#" /etc/php5/apache2/php.ini
	echo "Set php.ini >>>> $var = $val"
done

echo "Configurating Permissions"
sudo adduser $SUDO_USER www-data
sudo chown -R www-data:www-data /var/www
sudo chown -R $SUDO_USER:www-data /var/www/html
sudo chown -R $SUDO_USER:www-data /var/lock/apache2
sudo find /var/www/ -type d -exec chmod 755 {} \;
sudo find /var/www/ -type f -exec chmod 644 {} \;

echo "Configurating Apache2"
ln -s /var/www/html/ /home/$SUDO_USER/www
sudo sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=$SUDO_USER/" /etc/apache2/envvars

echo "Restarting Apache"
sudo service apache2 restart
sudo service mysql restart
