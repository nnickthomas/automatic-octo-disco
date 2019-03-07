#!/bin/bash

#A script for configuring default values on swift
#Run this script on your storage node
#Maintained by Nick Thomas
#Before running.....
	#1) Do the prerequisites at https://docs.openstack.org/swift/latest/install/storage-install-ubuntu-debian.html

#Static values*****
ip="192.168.0.1"
file="proxy-server.conf"
file2="container-server.conf"
file3="object-server.conf"
#file="/etc/swift/account-server.conf"
#file2="/etc/swift/container-server.conf"
#file3="/etc/swift/object-server.conf"
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
cp $file BACKUPnode
cleanFile $file

#Configure and Install Components
#apt-get install swift swift-account swift-container swift-object -y
#curl -o /etc/swift/account-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/account-server.conf-sample?h=stable/queens
#curl -o /etc/swift/container-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/container-server.conf-sample?h=stable/queens
#curl -o /etc/swift/object-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/object-server.conf-sample?h=stable/queens

#file1
changeFile "\[DEFAULT\]" "bind_ip = $ip" $file
changeFile "\[DEFAULT\]" "bind_port = 6202" $file
changeFile "\[DEFAULT\]" "user = swift" $file
changeFile "\[DEFAULT\]" "swift_dir = /etc/swift" $file
changeFile "\[DEFAULT\]" "devices = /srv/node" $file
changeFile "\[DEFAULT\]" "mount_check = True" $file

changeFile "\[pipeline\:main\]" "pipeline = healthcheck recon account-server" $file
changeFile "\[pipeline\:recon\]" "use = egg:swift#recon" $file
changeFile "\[pipeline\:recon\]" "recon_cache_path = /var/cache/swift" $file

#file2
changeFile "\[DEFAULT\]" "bind_ip = $ip" $file2
changeFile "\[DEFAULT\]" "bind_port = 6202" $file2
changeFile "\[DEFAULT\]" "user = swift" $file2
changeFile "\[DEFAULT\]" "swift_dir = /etc/swift" $file2
changeFile "\[DEFAULT\]" "devices = /srv/node" $file2
changeFile "\[DEFAULT\]" "mount_check = True" $file2

changeFile "\[pipeline\:main\]" "pipeline = healthcheck recon container-server" $file2
changeFile "\[filter\:recon\]" "use = egg:swift#recon" $file2
changeFile "\[filter\:recon\]" "recon_cache_path = /var/cache/swift" $file2

#file3
changeFile "\[DEFAULT\]" "bind_ip = $ip" $file3
changeFile "\[DEFAULT\]" "bind_port = 6202" $file3
changeFile "\[DEFAULT\]" "user = swift" $file3
changeFile "\[DEFAULT\]" "swift_dir = /etc/swift" $file3
changeFile "\[DEFAULT\]" "devices = /srv/node" $file3
changeFile "\[DEFAULT\]" "mount_check = True" $file3

changeFile "\[pipeline\:main\]" "pipeline = healthcheck recon container-server" $file3
changeFile "\[filter\:recon\]" "use = egg:swift#recon" $file3
changeFile "\[filter\:recon\]" "recon_lock_path = /var/lock" $file3

#chown -R swift:swift /srv/node
#mkdir -p /var/cache/swift
#chown -R root:swift /var/cache/swift
#chmod -R 775 /var/cache/swift
