#
# Cookbook Name:: ajenti1
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe "yum"
include_recipe "users"

execute "update" do
	command "yum update -y"
	action :run
end

execute "enable-epel-repository" do
	command "yum-config-manager --quiet --enable epel"
	action :run
end

execute "update" do
	command "yum update -y"
	action :run
end

yum_repository "ajenti" do
	name "Ajenti"
	url "http://repo.ajenti.org/centos/"
	action :add
end

package ["gcc","openssl-devel","python-devel","openldap-devel","libstdc++-devel","gcc-c++","fuse-devel","curl-devel","libxml2-devel","mailcap","automake","git"]

execute "upgrade-pip" do
	command "pip install --upgrade pip"
	action :run
end

execute "pip-ajenti" do
	command "/usr/local/bin/pip install ajenti"
	action :run
end

package ["ajenti","ajenti-v","ajenti-v-mail","ajenti-v-nginx","ajenti-v-mysql","ajenti-v-php7.0-fpm","ajenti-v-php-fpm"]

service 'ajenti' do
	action [:enable, :start]
end
