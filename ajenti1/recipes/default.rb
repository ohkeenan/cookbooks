#
# Cookbook Name:: ajenti1
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

execute "enable-epel-repository" do
	command "yum-config-manager --quiet --enable epel"
	action :run
	not_if "yum repolist | grep epel"
end

execute "update" do
	command "yum update -y"
	action :run
end

execute "install_ajenti_rpm" do
	command "rpm -ivh http://repo.ajenti.org/ajenti-repo-1.0-1.noarch.rpm"
	action :run
	not_if "yum list | grep ajenti-repo"
end

package ["gcc","openssl-devel","python-devel","openldap-devel","libstdc++-devel","gcc-c++","fuse-devel","curl-devel","libxml2-devel","mailcap","automake","git"]

python_execute 'upgrade pip' do
	action :run
	command "-m pip install --upgrade pip"
end

python_execute 'install ajenti' do
	action :run
	command "-m pip install ajenti"
	not_if { ::File.exists?('/usr/bin/ajenti-panel')}
end

package ["ajenti","ajenti-v","ajenti-v-mail","ajenti-v-nginx","ajenti-v-mysql","ajenti-v-php7.0-fpm","ajenti-v-php-fpm","php70-mysqlnd","php70-fpm"]

execute 'configure php7' do
	command "unlink /etc/alternatives/php && unlink /etc/alternatives/php-fpm && unlink /etc/alternatives/php-fpm-init && ln -s /usr/bin/php7 /etc/alternatives/php && ln -s /usr/sbin/php-fpm-7.0 /etc/alternatives/php-fpm && ln -s /etc/rc.d/init.d/php-fpm-7.0 /etc/alternatives/php-fpm-init"
	action :run
	not_if "ls -l /etc/alternatives/php | grep 7"
end

service 'ajenti' do
    action [:enable, :start]
end

service 'ajenti' do
	action [:restart]
	not_if "cat /etc/passwd | grep www-data"
end
execute 'apply ajenti-v' do
	command 'ajenti-ipc v apply'
	action :run
	not_if "cat /etc/passwd | grep www-data"
end

execute 'import first website' do
	command 'ajenti-ipc v import /home/ec2-user/rt/website.json && rm /home/ec2-user/rt/website.json && ajenti-ipc v apply'
	action :run
	only_if { ::File.exists?('/home/ec2-user/rt/website.json')}
end
