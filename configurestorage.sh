#!/bin/bash

#A script for configuring default values on cinder
#Maintained by Nick Thomas
#Before running.....
	#1) apt install lvm2 thin-provisioning-tools cinder-volume
	#2) pvcreate /dev/sdb
	#3) vgcreate cinder-volumes /dev/sdb
	#4) Comment out or remove any other options in the [keystone_authtoken] section.


#Static values*****
ip="192.168.0.1"
file="cinder.conf"
#file="/etc/cinder/cinder.conf"

#Steps 1-3
#apt install lvm2 thin-provisioning-tools cinder-volume
#pvcreate /dev/sdb
#vgcreate cinder-volumes /dev/sdb


cleanFile () {
	sed -i 's/^#.*$//g' "$1"
	sed -i '/^[[:space:]]*$/d' "$1"
}

#Function to do this for me
changeFile () {
	#sed -i '/\[example\]/ a example' example.conf
	#matches on 1, adds 2, on file 3
	sed -i "/$1/ a$2" $3
}
#Always make a backup!
cp $file BACKUP
cleanFile $file

#2
changeFile "\[database\]" "connection = mysql+pymysql://cinder:password@controller/cinder" $file
changeFile "\[DEFAULT\]" "transport_url = rabbit://openstack:password@controller" $file
changeFile "\[DEFAULT\]" "auth_strategy = keystone" $file
changeFile "\[DEFAULT\]" "my_ip = $ip" $file
changeFile "\[DEFAULT\]" "enabled_backends = lvm" $file
changeFile "\[DEFAULT\]" "glance_api_servers = http://controller:9292" $file

#Comment out or remove any other options in the [keystone_authtoken] section.
changeFile "\[keystone\_authentication\]" "auth_uri = http://controller:5000" $file
changeFile "\[keystone\_authentication\]" "auth_url = http://controller:5000" $file
changeFile "\[keystone\_authentication\]" "memcached_servers = controller:11211" $file
changeFile "\[keystone\_authentication\]" "auth_type = password" $file
changeFile "\[keystone\_authentication\]" "project_domain_id = default" $file
changeFile "\[keystone\_authentication\]" "user_domain_id = default" $file
changeFile "\[keystone\_authentication\]" "project_name = service" $file
changeFile "\[keystone\_authentication\]" "username = cinder" $file
changeFile "\[keystone\_authentication\]" "password = password" $file

changeFile "\[lvm\]" "volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver" $file
changeFile "\[lvm\]" "volume_group = cinder-volumes" $file
changeFile "\[lvm\]" "iscsi_protocol = iscsi" $file
changeFile "\[lvm\]" "iscsi_helper = tgtadm" $file

changeFile "\[oslo_concurrency\]" "lock_path = /var/lib/cinder/tmp" $file

#service tgt restart
#service cinder-volume restart
