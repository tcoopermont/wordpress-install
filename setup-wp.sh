#!/usr/bin/env bash

#installs wordpress and dependencies 
#Author: tomcooper@tec8.net
#Date: 2019-08-09
#todo: check for ufw firewall

mysql_package="mysql-server"
web_package="nginx"
web_modules="mod_rewrite" #looks like this is installed in main package
php_package="php-fpm"
php_modules="php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip"

mysql_root_pw="default"

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
else
  echo "php version $dpkg_result already installed" #need to cut
fi
exit

#create wordpress user,db and grants
echo "create user '$wp_db_user'@'localhost' identified by $wp_db_pw;" | mysql -u root -p${mysql_root_ps} &&
echo "create database $wp_db_name;" | mysql -u root -p${mysql_root_ps} &&
echo "grant all privileges on $wp_db_name.* to '$wp_db_user'@'localhost';FLUSH PRIVILEGES;" \
      | mysql -u root -p${mysql_root_ps}
if [ $? -ne 0 ]
then
  echo "error in mysql tasks"
  exit
fi

sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default


sudo nginx -t

sudo systemctl reload nginx
