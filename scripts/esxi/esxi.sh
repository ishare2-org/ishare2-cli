#!/bin/bash

###### Updated 2 By Maosen - 20170419 ######
###### Updated 3 - 20221016 ######

#qemu=$(pwd)
qemu=$1

icon="/opt/unetlab/html/images/icons"
include="/opt/unetlab/html/includes"
template="/opt/unetlab/html/templates"

if [[ ${qemu:25:5} == 'esxi-' ]]
then
    cp -rf $qemu/esxi.png $icon/esxi.png
    #rm -rf $qemu/esxi.png
    
    cp -rf $qemu/esxi.php $template/esxi.php
    #rm -rf $qemu/esxi.php
    
    if grep -i ESXi $include/init.php > /dev/null
    then
        echo -e "\033[33mSorry!\033[0m Maybe, you have already imported it"
    else
        sed -i "/Virtual PC/i\\\t\t'esxi'\t\t\t=>\t'VMware ESXi'," $include/init.php
        echo 'options kvm_intel nested=1' >>  /etc/modprobe.d/kvm-intel.conf
        echo 'options kvm ignore_msrs=1' >>  /etc/modprobe.d/kvm-intel.conf
        echo -e "\033[32mGreat!\033[0m ESXi device has been imported successfully"
        echo -e "\nDon´t forget to connect to this device using VNC."
        echo -e "You can download UltraVNC Viewer, for example"
    fi
    #rm -rf $qemu/esxi.sh
else
    echo -e "\033[33mSorry!\033[0m Your folder name is not correct, please modify it and then run the script again\n\033[32mFor example: \"esxi-xxxx\"\033[0m"
fi
