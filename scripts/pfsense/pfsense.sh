#!/bin/bash 

###### Update 2 By Maosen 20170419 ######
###### Updated 3 - 20221030 ######

#qemu=$(pwd)
qemu=$1

icon="/opt/unetlab/html/images/icons"
include="/opt/unetlab/html/includes"
template="/opt/unetlab/html/templates" 

cp -rf $qemu/pfsense.php $template/pfsense.php
#rm -rf $qemu/pfsense.php

echo -e "\033[32mGreat!\033[0m pfSense device has been imported successfully"
#rm -rf $qemu/pfsense.sh
