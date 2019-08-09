#!/bin/bash -x

##!/usr/bin/env bash

#installs wordpress and dependencies 
#Author: tomcooper@tec8.net
#Date: 2019-08-09
#todo: check for ufw firewall

mysql_package="mysql-server"
web_package="nginx"
web_modules="mod_rewrite" #looks like this is installed in main package
php_package="php-fpm"
php_modules="php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip"

#using integrated os login
#mysql_root_pw="default"

wp_db_name="examplecom_db"
wp_db_user="examplecom_user"
wp_db_pw="!apw4wpex%"


sudo apt-get update
#check for error

 
#get the new or existing root db pw
echo "get root db password" #how to auto this in 

dpkg_result=$(dpkg-query --show $mysql_package)
if [ $? -ne 0 ]
then
  echo "installing $mysql_package"
  sudo apt-get install $mysql_package
  echo "setup $mysql_package" 
  #sudo mysql_secure_installation
else
  echo "mysql version $dpkg_result already installed" #need to cut
fi

dpkg_result=$(dpkg-query --show $web_package)
if [ $? -ne 0 ]
then
  echo "installing $web_package"
  sudo apt-get install $web_package
else
  echo "nginx version $dpkg_result already installed" #need to cut
fi

dpkg_result=$(dpkg-query --show $php_package)
if [ $? -ne 0 ]
then
  echo "installing $php_package"
  sudo apt-get install $php_package
  sudo apt-get install $php_modules
else
  echo "php version $dpkg_result already installed" #need to cut
fi

#create wordpress user,db and grants
echo "create user '$wp_db_user'@'localhost' identified by '$wp_db_pw';" | sudo mysql -u root &&
echo "create database $wp_db_name;" | sudo mysql -u root  &&
echo "grant all privileges on $wp_db_name.* to '$wp_db_user'@'localhost';FLUSH PRIVILEGES;" \
      | sudo mysql -u root 
if [ $? -ne 0 ]
then
  echo "error in mysql tasks"
  exit
fi

#add hosts entry
echo "127.0.0.1 example.com" | sudo tee -a /etc/hosts
#install wordpress
#sudo cp index.html /var/www/wordpress/index.html
wget http://wordpress.org/latest.zip
sudo unzip -q latest.zip -d /var/www/
sudo cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
sudo sed -i "s/database_name_here/$wp_db_name/" /var/www/wordpress/wp-config.php
sudo sed -i "s/username_here/$wp_db_user/" /var/www/wordpress/wp-config.php
sudo sed -i "s/password_here/$wp_db_pw/" /var/www/wordpress/wp-config.php
grep DB /var/www/wordpress/wp-config.php
sudo chown -R www-data:www-data /var/www/wordpress


sudo cp example.com.conf /etc/nginx/sites-available/example.com
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default


sudo nginx -t

sudo systemctl reload nginx

rm latest.zip 

