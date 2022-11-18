#!/bin/bash
 
###### Version 3 By Maosen 20170618 ######
###### Updated 4 - 20221030 ######

# Author: Maosen Sun <sunnymaosen@gmail.com,sun285529808@qq.com>
# Copyright: Maosen Sun
# Organization: EmulatedLab (QQ Group:593920308)
# @link http://www.eve-ng.com
# @version 20170618

#qemu=$(pwd)
qemu=$1

icon="/opt/unetlab/html/images/icons"
include="/opt/unetlab/html/includes"
template="/opt/unetlab/html/templates" 

if [[ ${qemu:25:10} == 'openstack-' ]]
then
	mv -f $qemu/Openstack.png $icon/Openstack.png
	mv -f $qemu/openstack.php $template/openstack.php
  
	if grep -i \'openstack\' $include/init.php > /dev/null
	then
		echo -e "\033[33mSorry!\033[0m Maybe, you have already imported it"
	else
		sed -i "/Linux/i\\\t\t'openstack'\t\t\t=>\t'Openstack'," $include/init.php
		echo -e "\033[32mGreat!\033[0m Openstack device has been imported successfully"
		echo -e "\nDon´t forget to connect to this device using VNC."
		echo -e "You can download UltraVNC Viewer, for example"
		echo -e "\nuser: root\npass: eve@123"
	fi
	#rm -rf $qemu/openstack.sh
else
	echo -e "\033[33mSorry!\033[0m Your folder name is not correct, please modify it and then run the script again\n\033[32mFor example: \"openstack-xxxx\"\033[0m"
fi
