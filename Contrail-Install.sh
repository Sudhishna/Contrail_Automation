#!/bin/bash
# OPENSTACK 10 WITH CONTRAIL 4.1 INSTALLATION USING SERVER-MANAGER
# Comannd example ./Contrail-Install.sh
# Date written 2018 March 9

HOME_DIR=/root/
INFO_PATH=$HOME_DIR/Contrail_Automation/Info.txt
TARGET_INFO_PATH=
cp /root/BuildAutomationSystem/Info.txt /root/Contrail_Automation/

echo ""
echo " **************************************************"
echo "      CONTRAIL HA-WEBSERVER DEPLOYMENT PROCESS"
echo " **************************************************"
echo ""
echo ""
echo "Populating data from Info.txt...."
echo ""
ip=`awk 'NR==1' $INFO_PATH`
file_server=`awk 'NR==2' $INFO_PATH`
miface=`awk 'NR==3' $INFO_PATH`


echo "FILE SERVER"
echo "IP Address: $file_server"
echo "CONTRAIL HOST")
echo " IP Address: $ip"
echo " Management Iface Name: $miface"
echo "***********************************")
echo "***********************************")
echo ""

while true; do
  read -p 'Confirm above details (Y?N) ? ' choice
  case $choice in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n";;
    esac
done

# Write the ip addresses into the inventory file used by Ansible
IFS='/' read -r -a vm_ip <<< "$ip"
IFS='/' read -r -a file_ip <<< "$file_server"

echo "[local]
localhost ansible_connection=local

[contrail-ubuntu-vm]
${vm_ip[0]}

[contrail-file-server]
${file_ip[0]}
" > /root/Contrail_Automation/Contrail-Install/all.inv

#Fetch necessary info from the target host
echo ""
echo "Fetching info from Contrail host..."
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/contrail-host-facts.yml --extra-vars 'iface=$miface'

hostname=`grep "hostname" target_info.txt | awk -F' ' '{print $2}'`
ip=`grep "ip" target_info.txt | awk -F' ' '{print $2}'`
mac=`grep "mac" target_info.txt | awk -F' ' '{print $2}'`
gw=`grep "mac" target_info.txt | awk -F' ' '{print $2}'`
iface=`grep "iface" target_info.txt | awk -F' ' '{print $2}'
ubuntu_version=`grep "ubuntu-version" target_info.txt | awk -F' ' '{print $2}'`
contrail_version=`grep "contrail-version" target_info.txt | awk -F' ' '{print $2}'`
openstack_version=`grep "openstack-version" target_info.txt | awk -F' ' '{print $2}'`
file_server=`awk 'NR==2' Info.txt`
openstack_release=`grep "openstack-release" target_info.txt | awk -F' ' '{print $2}'`

echo ""
echo ""
echo " ********************************************"
echo "           TARGET MACHINE DETAILS"
echo " ********************************************"
echo ""
echo " * HOSTNAME          : $hostname"
echo ""
echo " * IP ADDRESS/CIDR   : $ip"
echo ""
echo " * GATEWAY           : $gw"
echo ""
echo " * MAC ADDRESS       : $gw"
echo ""
echo " * UBUNTU OS VERSION : $ubuntu_version "
echo ""
echo ""
echo " ********************************************"
echo "           CONTRAIL SETUP DETAILS"
echo " ********************************************"
echo ""
echo " * CLUSTER ID        : $id"
echo ""
echo " * CONTRAIL VERSION  : $contrail_version"
echo ""
echo " * OPENSTACK SKU     : $openstack_version"
echo ""
echo " * OPENSTACK RELEASE : $openstack_release"
echo ""
echo " * FILE SERVER       : $file_server"
echo ""
echo " ********************************************"


while
    read -p 'Confirm the details (Y/N): ' answer

    if [ "$answer" = "n" ] || [ "$answer" = "N" ] || [ "$answer" = "no" ] || [ "$answer" = "No" ] || [ "$answer" = "NO" ]
    then
        echo "Important: Please edit the target machine and contrail setup details in the file /root/Contrail_Automation/target_info.txt"
        echo "Edit file server IP in line 2 of /root/Contrail_Automation/Info.txt"
        echo "After editing, run the setup file ./Contrail-Install.sh"
        exit 1
    elif [ "$answer" = "y" ] || [ "$answer" = "Y" ] || [ "$answer" = "yes" ] || [ "$answer" = "Yes" ] || [ "$answer" = "YES" ]
    then
        break
    fi
do :;  done

echo ""
echo " ********************************************"
echo ""

while
    read -p 'PROCEED WITH THE CONTRAIL SETUP?? (Y/n): ' answer

    if [ "$answer" = "n" ] || [ "$answer" = "N" ] || [ "$answer" = "no" ] || [ "$answer" = "No" ] || [ "$answer" = "NO" ]
    then
        exit 1
    elif [ "$answer" = "y" ] || [ "$answer" = "Y" ] || [ "$answer" = "yes" ] || [ "$answer" = "Yes" ] || [ "$answer" = "YES" ]
    then
        break
    fi
do :;  done

echo ""

echo "contrail_package:
  -
    id: '$id'
    contrail_version: '$contrail_version'
    openstack_sku: '$openstack_version'
    openstack_release: '$openstack_release'
    file_server: '$file_server'
host_vm:
  -
    hostname: '$hostname'
    ubuntu_version: '$ubuntu_version'
    mac_address: '$mac'
    ip_address: '$ip'
    default_gateway: '$gw'
    management_interface: '$iface'
" > /root/Contrail_Automation/Contrail-Install/vars/contrail.info

IFS='/' read -r -a vm_ip <<< "$ip_address"
IFS='/' read -r -a file_ip <<< "$file_server"

echo "[local]
localhost ansible_connection=local

[contrail-ubuntu-vm]
${vm_ip[0]}

[contrail-file-server]
${file_ip[0]}
" > /root/Contrail_Automation/Contrail-Install/all.inv

echo ""
echo ""
echo "##############################################################"
echo "                     CONTRAIL SETUP BEGINS"
echo "##############################################################"
echo ""
echo ""

echo ""
echo ""
echo "##############################################################"
echo "              Initialize the Destination VM"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/init.yml
echo "################## Intialize - Complete ######################"
sleep 2

echo ""
echo ""
echo "##############################################################"
echo "                      Contrail Deploy"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/01-contrail-server-manager.yml
echo "################# Contrail Deploy - Complete #################"
sleep 5

echo ""
echo ""
echo "##############################################################"
echo "                        Network Deploy"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/02-deploy-networks.yml
echo "################## Network Deploy - Complete #################"
sleep 2

echo ""
echo ""
echo "##############################################################"
echo "                      Image Preparation"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/03-image-prep/image-prep.yml
echo "################# Image Preparation - Complete ################"
sleep 2

echo ""
echo ""
echo "##############################################################"
echo "                        Image Upload"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/04-image-upload.yml
echo "################## Image Upload - Complete ###################"
sleep 2

echo ""
echo ""
echo "##############################################################"
echo "                            Flavors"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/05-create-flavors.yml
printf  "Flavors were created.\r"
echo "####################### Flavors - Complete ###################"
sleep 2

echo ""
echo ""
echo "##############################################################"
echo "                        Server Creation"
echo "##############################################################"
echo ""
echo ""
ansible-playbook -i Contrail-Install/all.inv Contrail-Install/06-create-servers.yml
echo "################## Server Creation - Complete #################"
sleep 2

printf "\n\nCONTRAIL SETUP COMPLETE.\n"
echo ""
echo ""
echo "################### CONTRAIL SETUP COMPLETE::: Please find the details below ###################"
echo ""
echo "                   ################## Openstack Dashboard #################"
echo "                   Url: http://<host ip>:8898"
echo "                   Username : admin"
echo "                   Password: contrail123"
echo ""
echo "                   ####################### Contrail UI ####################"
echo "                   Url: https://<host ip>:8143"
echo "                   Username: admin"
echo "                   Password: contrail123"
echo ""
echo "                   ################### GUI host credentials ###############"
echo "                   Username: juniper"
echo "                   Password: juniper123"
echo ""
echo "                   ################ Other nodes credentials ###############"
echo "                   Username: root"
echo "                   Password: juniper123"
echo ""
echo "                   ################### Database details ###################"
echo "                   Name: wordpress"
echo "                   Username: wpuser"
echo "                   Password: password"
echo ""
echo "                   ################# Website credentials ##################"
echo "                   User: adminuser"
echo "                   Password: password"
echo ""
echo "################################################################################################"
