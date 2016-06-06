#!/usr/bin/env bash

PASSWORD='1234'
PROJECTFOLDER='/home/vagrant/public_html'

sudo mkdir "${PROJECTFOLDER}"
sudo mkdir "${PROJECTFOLDER}/logs-errors"

sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get install -y apache2
sudo apt-get install -y php5

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

VHOST=$(cat <<EOF
<VirtualHost *:80>

        DocumentRoot "/home/vagrant/public_html"
        AddHandler cgi-script .cgi .pl

        <Directory "/home/vagrant/public_html">
                AllowOverride All
                Require all granted
                DirectoryIndex index.cgi index.pl index.py index.php index.html
                Options ExecCGI Indexes FollowSymLinks
        </Directory>

        ErrorLog /home/vagrant/public_html/logs-errors/error.log
        CustomLog /home/vagrant/public_html/logs-errors/access.log combined

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

sudo a2enmod rewrite
sudo a2enmod cgi

service apache2 restart

curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
