#!/bin/bash
# OPENSTACK 10 WITH CONTRAIL 4.1 INSTALLATION USING SERVER-MANAGER
# Comannd example ./Contrail-Install.sh
# Date written 2018 March 9

printf  "Contrail Setup Begins.\r"

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/init.yml
printf  "Initialized the Destination VM\r"
sleep 2

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/01-contrail-server-manager.yml
printf  "Contrail Server Manager Installed.\r"
sleep 5

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/02-deploy-networks.yml
printf  "Networks Deployed.\r"
sleep 2

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/03-image-prep/image-prep.yml
printf  "Prepared Images.\r"
sleep 2

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/04-image-upload.yml
printf  "Uploaded the Images to glance.\r"
sleep 2

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/05-create-flavors.yml
printf  "Flavors were created.\r"
sleep 2

ansible-playbook -i Contrail-Install/all.inv Contrail-Install/06-create-servers.yml
printf  "Servers were created succesfully.\r"
sleep 2

printf "\n\nCONTRAIL SETUP COMPLETE.\n"
