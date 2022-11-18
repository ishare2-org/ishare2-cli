#!/bin/bash 

######Version 2 By Maosen 20170419######
###### Updated 4 - 20221107 ######

# Author: Maosen Sun <sunnymaosen@gmail.com,sun285529808@qq.com>
# copyright: Maosen Sun
# Organization EmulatedLab(QQ Group:593920308)
# @link http://www.eve-ng.com
# @version 20170518

#qemu=$(pwd)
qemu=$1

icon="/opt/unetlab/html/images/icons"
include="/opt/unetlab/html/includes"
template="/opt/unetlab/html/templates"

if [[ ${qemu:25:7} == 'zabbix-' ]]
then
    mv -f $qemu/Zabbix.png $icon/Zabbix.png
    mv -f $qemu/zabbix.php $template/zabbix.php
    
    if grep -i \'zabbix\' $include/init.php > /dev/null
    then
        echo -e "\033[33mSorry!\033[0m Maybe, you have already imported it"
    else
        sed -i "/Virtual PC/i\\\t\t'zabbix'\t\t\t=>\t'Zabbix'," $include/init.php
        echo -e "\033[32mGreat!\033[0m Zabbix device has been imported successfully"
        echo -e "\nDon´t forget to connect to this device using VNC."
	echo -e "You can download UltraVNC Viewer, for example"
    fi
    #rm -rf $qemu/zabbix.sh
else
    echo -e "\033[33mSorry!\033[0m Your folder name is not correct, please modify it and then run the script again\n\033[32mFor example: \"zabbix-xxxx\"\033[0m"
fi
