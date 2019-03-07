#!/bin/bash

#Run this on your storage node
#A script for configuring default values on cinder
#Maintained by Nick Thomas
#Before running....
	#1) Configure a storage node
	#2) Comment out or remove any other options in the [keystone_authtoken] section.

#Static values*************************
ip="192.168.0.1"
file="cinder.conf"
file2="nova.conf"
#file="/etc/cinder/cinder.conf"
#file2="/etc/nova/nova.conf"
url="URLHERE" #openstack catalog show object-store
#My FUnctions***************************
cleanFile () {
	sed -i 's/^#.*$//g' "$1"
	sed -i '/^[[:space:]]*$/d' "$1"
}

changeFile () {
	#sed -i '/\[example\]/ a example' example.conf
	#matches on 1, adds 2, on file 3
	sed -i "/$1/ a$2" $3
}

#Always make a backup!*******************
cp $file BACKUPbackup
cleanFile $file


#Okay 3, 2, 1, Lets Jam******************
#Install and Configure Components
apt install cinder-backup

changeFile "\[DEFAULT\]" "backup_driver = cinder.backup.drivers.swift" $file
changeFile "\[DEFAULT\]" "backup_swift_url = $url" $file

#Finalize Installation
service cinder-backup restart
