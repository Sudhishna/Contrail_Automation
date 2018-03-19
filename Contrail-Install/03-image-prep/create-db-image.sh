#!/bin/bash

cp images/ubuntu-image.img images/ubuntu-db.img

virt-customize -a images/ubuntu-db.img \
--root-password password:juniper123 \
--hostname db-server \
--firstboot image-prep/db-fb.sh \
--run-command 'echo "ubuntu ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/ubuntu' \
--chmod 0440:/etc/sudoers.d/ubuntu \
--install mysql-server,mysql-client \
--run-command 'cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf' \
--run-command 'sed -i "/^bind-address/c\bind-address = 0.0.0.0" /etc/mysql/my.cnf'
