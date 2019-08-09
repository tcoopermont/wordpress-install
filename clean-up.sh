#! /bin/bash -x

wp_db_name="examplecom_db"
wp_db_user="examplecom_user"

echo "drop user '$wp_db_user'@'localhost' ;" | sudo mysql -u root &&
echo " drop database $wp_db_name;" | sudo mysql -u root 


sudo unlink /etc/nginx/sites-enabled/example.com
sudo rm /etc/nginx/sites-available/example.com
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo rm -rf /var/www/wordpress

grep -v example /etc/hosts | sudo tee /etc/hosts

