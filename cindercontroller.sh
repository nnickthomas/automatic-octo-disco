#!/bin/bash

#Run this on your controller node
#A script for configuring default values on cinder
#Maintained by Nick Thomas
#Before running....
	#1) DO the prerequisites here https://docs.openstack.org/cinder/queens/install/cinder-controller-install-ubuntu.html
	#2) Comment out or remove any other options in the [keystone_authtoken] section.
	#3) Add a section called [keystone_authtoken] to your /etc/cinder/cinder.conf


#Static values*************************
ip="192.168.0.1"
file="cinder.conf"
file2="nova.conf"
#file="/etc/cinder/cinder.conf"
#file2="/etc/nova/nova.conf"

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
cp $file BACKUP
cleanFile $file
cleanFile $file2


#Okay 3, 2, 1, Lets Jam******************
#Install and Configure Components
apt install cinder-api cinder-scheduler

changeFile "\[database\]" "connection = mysql+pymysql://cinder:password@controller/cinder" $file
changeFile "\[DEFAULT\]" "transport_url = rabbit://openstack:password@controller" $file
changeFile "\[DEFAULT\]" "auth_strategy = keystone" $file
changeFile "\[DEFAULT\]" "my_ip = $ip" $file

changeFile "\[keystone\_authentication\]" "auth_uri = http://controller:5000" $file
changeFile "\[keystone\_authentication\]" "auth_url = http://controller:5000" $file
changeFile "\[keystone\_authentication\]" "memcached_servers = controller:11211" $file
changeFile "\[keystone\_authentication\]" "auth_type = password" $file
changeFile "\[keystone\_authentication\]" "project_domain_id = default" $file
changeFile "\[keystone\_authentication\]" "user_domain_id = default" $file
changeFile "\[keystone\_authentication\]" "project_name = service" $file
changeFile "\[keystone\_authentication\]" "username = cinder" $file
changeFile "\[keystone\_authentication\]" "password = password" $file

changeFile "\[oslo_concurrency\]" "lock_path = /var/lib/cinder/tmp" $file

#su -s /bin/sh -c "cinder-manage db sync" cinder

#Configure Compute to use Block Storage
changeFile "\[cinder\]" "os_region_name = RegionOne" $file2

#Finalize Installation
#service nova-api restart
#service cinder-scheduler restart
#service apache2 restart
