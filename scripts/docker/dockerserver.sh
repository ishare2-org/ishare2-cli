#!/bin/bash

###### Update 3 By Maosen 20170610 ######
###### Updated 3 - 20221030 ######

#qemu=$(pwd)
qemu=$1

icon="/opt/unetlab/html/images/icons"
include="/opt/unetlab/html/includes"
template="/opt/unetlab/html/templates" 

if [[ ${qemu:25:13} == 'dockerserver-' ]]
then
	mv -f $qemu/Docker.png $icon/Docker.png
	mv -f $qemu/dockerserver.php $template/dockerserver.php
  
	if grep -i \'dockerserver\' $include/init.php > /dev/null
	then
		echo -e "\033[33mSorry!\033[0m Maybe, you have already imported it"
	else
		sed -i "/Linux/a\\\t\t'dockerserver'\t\t\t=>\t'Docker'," $include/init.php
		echo -e "\033[32mGreat!\033[0m Docker server device has been imported successfully"
	fi
	# rm -rf $qemu/dockerserver.sh
else
	echo -e "\033[33mSorry!\033[0m Your folder name is not correct, please modify it and then run the script again\n\033[32mFor example: \"dockerserver-xxxx\"\033[0m"
fi
