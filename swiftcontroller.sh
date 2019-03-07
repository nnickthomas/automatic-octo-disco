#!/bin/bash

#A script for configuring default values on swift
#Run this script on your controller node
#Maintained by Nick Thomas
#Before running.....
	#1) Do the prerequisites at https://docs.openstack.org/swift/latest/install/controller-install-ubuntu.html

#Static values*****
ip="192.168.0.1"
file="proxy-server.conf"
#file="/etc/proxy-server/proxy-server.conf"

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

#Configure and Install Components
#apt install swift swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware memcached -y
#mkdir /etc/swift/
#curl -o /etc/swift/proxy-server.conf https://git.openstack.org/cgit/openstack/swift/plain/etc/proxy-server.conf-sample?h=stable/queens
cleanFile $file

changeFile "\[DEFAULT\]" "bind_port = 8080" $file
changeFile "\[DEFAULT\]" "user = swift" $file
changeFile "\[DEFAULT\]" "swift_dir = /etc/swift" $file

changeFile "\[pipeline\:main\]" "pipeline = catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server" $file
changeFile "\[app\:proxy\-server\]" "use = egg:swift#proxy" $file
changeFile "\[app\:proxy\-server\]" "account_autocreate = True" $file

changeFile "\[filter\:keystoneauth\]" "use = egg:swift#keystoneauth" $file
changeFile "\[filter\:keystoneauth\]" "operator_roles = admin,user" $file

changeFile "\[filter\:keystone\_authentication\]" "paste.filter_factory = keystonemiddleware.auth_token:filter_factory" $file
changeFile "\[filter\:keystone\_authentication\]" "www_auth_uri = http://controller:5000" $file
changeFile "\[filter\:keystone\_authentication\]" "auth_url = http://controller:5000" $file
changeFile "\[filter\:keystone\_authentication\]" "memcached_servers = controller:11211" $file
changeFile "\[filter\:keystone\_authentication\]" "auth_type = password" $file
changeFile "\[filter\:keystone\_authentication\]" "project_domain_id = default" $file
changeFile "\[filter\:keystone\_authentication\]" "user_domain_id = default" $file
changeFile "\[filter\:keystone\_authentication\]" "project_name = service" $file
changeFile "\[filter\:keystone\_authentication\]" "username = cinder" $file
changeFile "\[filter\:keystone\_authentication\]" "password = password" $file
changeFile "\[filter\:keystone\_authentication\]" "delay_auth_decision = True" $file

changeFile "\[filter\:cache\]" "memcache_servers = controller:11211" $file
changeFile "\[filter\:cache\]" "use = egg:swift#memcache" $file
