#!/bin/bash

# Copy the original ubuntu image to primary image
cp images/ubuntu-image.img images/ubuntu-webserver-primary.img

# Customize the image
virt-customize -a images/ubuntu-webserver-primary.img \
--root-password password:juniper123 \
--hostname ws-primary \
--firstboot image-prep/ws-primary-fb.sh \
--run-command 'echo "ubuntu ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/ubuntu' \
--chmod 0440:/etc/sudoers.d/ubuntu \
--install apache2,tasksel,mysql-server,mysql-client,arp-scan,sshpass,expect \
--install php7.0,libapache2-mod-php7.0,php7.0-mysql \
--install php7.0-curl,php7.0-json,php7.0-cgi \
--install php-curl,php-gd,php-mbstring,php-mcrypt,php-xml,php-xmlrpc \
--run-command 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config' \
--run-command 'sed -i "/^KeepAlive/c\KeepAlive  On" /etc/apache2/apache2.conf' \
--run-command 'sed -i "/^MaxKeepAliveRequests/c\MaxKeepAliveRequests  50" /etc/apache2/apache2.conf' \
--run-command 'sed -i "/^KeepAliveTimeout/c\KeepAliveTimeout  5" /etc/apache2/apache2.conf' \
--run-command 'a2dismod mpm_event' \
--run-command 'a2enmod mpm_prefork' \
--run-command 'systemctl restart apache2' \
--run-command 'cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/example.com.conf' \
--copy-in image-prep/jnpr-example.com.conf:/etc/apache2/sites-available/ \
--run-command 'sudo mkdir -p /var/www/html/jnpr-example.com/logs' \
--run-command 'sudo mkdir -p /var/www/html/jnpr-example.com/public_html' \
--run-command 'a2ensite jnpr-example.com.conf' \
--run-command 'a2dissite 000-default.conf' \
--run-command 'systemctl reload apache2' \
--run-command 'sed -i "/^error_log/c\error_log = /var/log/php/error.log" /etc/php/7.0/apache2/php.ini' \
--run-command 'sed -i "/^error_reporting/c\error_reporting = E_COMPILE_ERROR | E_RECOVERABLE_ERROR | E_ERROR | E_CORE_ERROR" /etc/php/7.0/apache2/php.ini' \
--run-command 'sed -i "/^max_input_time/c\max_input_time = 30" /etc/php/7.0/apache2/php.ini' \
--run-command 'sed -i "/^;error_log/c\error_log = /var/log/php/error.log" /etc/php/7.0/apache2/php.ini' \
--run-command 'sed -i "/^;error_reporting/c\error_reporting = E_COMPILE_ERROR | E_RECOVERABLE_ERROR | E_ERROR | E_CORE_ERROR" /etc/php/7.0/apache2/php.ini' \
--run-command 'sed -i "/^;max_input_time/c\max_input_time = 30" /etc/php/7.0/apache2/php.ini' \
--run-command 'mkdir /var/log/php' \
--run-command 'chown www-data /var/log/php' \
--run-command 'systemctl restart apache2' \
--run-command 'mkdir /var/www/html/jnpr-example.com/src/' \
--run-command 'chown -R www-data:www-data /var/www/html/jnpr-example.com/' \
--run-command 'wget http://wordpress.org/latest.tar.gz' \
--run-command 'tar -xvf latest.tar.gz' \
--run-command 'mv wordpress/* /var/www/html/jnpr-example.com/public_html/' \
--run-command 'chown -R www-data:www-data /var/www/html/jnpr-example.com/public_html' \
--install lsyncd \
--run-command 'sudo mkdir /etc/lsyncd' \
--copy-in image-prep/lsyncd.conf.lua:/etc/lsyncd/ \
--run-command 'curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar' \
--run-command 'php wp-cli.phar --info' \
--run-command 'chmod +x wp-cli.phar' \
--run-command 'sudo mv wp-cli.phar /usr/local/bin/wp'
