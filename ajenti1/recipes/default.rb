#
# Cookbook Name:: ajenti1
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe "yum"

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

if `rpm -qa | grep "ajenti-repo-1.0-1.noarch"`.empty?
	execute "install_ajenti_rpm" do
		command "rpm -ivh http://repo.ajenti.org/ajenti-repo-1.0-1.noarch.rpm"
		action :run
	end
end

package ["gcc","openssl-devel","python-devel","openldap-devel","libstdc++-devel","gcc-c++","fuse-devel","curl-devel","libxml2-devel","mailcap","automake","git"]

python_execute 'upgrade pip' do
	action :run
	command "pip install --upgrade pip"
end

python_execute 'install ajenti' do
	action :run
	command "/usr/local/bin/pip install ajenti"
end

package ["ajenti","ajenti-v","ajenti-v-mail","ajenti-v-nginx","ajenti-v-mysql","ajenti-v-php7.0-fpm","ajenti-v-php-fpm"]

package ["php70-mysqlnd","php70-fpm"]

if `ls -l /etc/alternatives/php | grep 7`.empty?
	execute 'configure php7' do
	command "unlink /etc/alternatives/php && unlink /etc/alternatives/php-fpm && unlink /etc/alternatives/php-fpm-init && ln -s /usr/bin/php7 /etc/alternatives/php && ln -s /usr/sbin/php-fpm-7.0 /etc/alternatives/php-fpm && ln -s /etc/rc.d/init.d/php-fpm-7.0 /etc/alternatives/php-fpm-init"
	action :run
	end
end

if `cat /etc/passwd | grep www-data`.empty?
	execute 'apply ajenti-v' do
	command 'ajenti-ipc v apply'
	action :run
	end
end
# Will fail here since directory probably isn't created yet at /srv/$DOMAIN

execute 'import first website' do
	command 'ajenti-ipc v import /home/ec2-user/rt/website.json && rm /home/ec2-user/rt/website.json && ajenti-ipc v apply'
	action :run
	only_if { ::File.exists?('/home/ec2-user/rt/website.json')}
end

service 'ajenti' do
	action [:enable, :start]
end
