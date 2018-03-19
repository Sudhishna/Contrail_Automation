#Make a copy of original ubuntu image to work upon
cp images/ubuntu-image.img images/ubuntu-webserver-secondary.img

#set environment for libvirt
export LIBGUESTFS_BACKEND=direct

#customize the webserver secondary image
virt-customize -a images/ubuntu-webserver-secondary.img \
--root-password password:juniper123 \
--hostname ws-sec \
--firstboot /root/image-prep/ws-sec-fb.sh \
--run-command 'echo "ubuntu ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/ubuntu' \
--chmod 0440:/etc/sudoers.d/ubuntu \
--install apache2,tasksel,mysql-server,mysql-client \
--install php7.0,libapache2-mod-php7.0,php7.0-mysql \
--install php7.0-curl,php7.0-json,php7.0-cgi \
--install php-curl,php-gd,php-mbstring,php-mcrypt,php-xml,php-xmlrpc \
--run-command 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config' \
--run-command 'sed -i "/^PermitRootLogin/c\PermitRootLogin  yes" /etc/ssh/sshd_config' \
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
--run-command 'chown -R www-data:www-data /var/www/html/jnpr-example.com/public_html'
