#
# Cookbook Name:: ajenti1
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

execute "enable epel repository" do
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
	not_if "python -m pip --version | grep 9.0.1"
end

python_execute 'install ajenti' do
	action :run
	command "-m pip install ajenti"
	not_if { ::File.exists?('/usr/bin/ajenti-panel')}
end

package ["ajenti","ajenti-v","ajenti-v-mail","ajenti-v-nginx","ajenti-v-mysql","ajenti-v-php7.0-fpm","ajenti-v-php-fpm","php70-mysqlnd","php70-fpm"]

service 'php-fpm' do
	action :stop
	only_if "ls -l /etc/alternatives/php-fpm | grep php-fpm-5"
end

execute 'unlink php5' do
	command "unlink /etc/alternatives/php"
	action :run
	only_if "ls -l /etc/alternatives/php | grep php-5"
end

execute 'unlink php-fpm5' do
	command "unlink /etc/alternatives/php-fpm"
	action :run
	only_if "ls -l /etc/alternatives/php-fpm | grep php-fpm-5"
end

execute 'unlink php-fpm5-init' do
	command "unlink /etc/alternatives/php-fpm-init"
	action :run
	only_if "ls -l /etc/alternatives/php-fpm | grep php-fpm-5"
end

execute 'set php to php7' do
	command "ln -s /usr/bin/php7 /etc/alternatives/php"
	action :run
	not_if { ::File.symlink?('/etc/alternatives/php') }
end

execute 'set php-fpm to php7' do
	command "ln -s /usr/sbin/php-fpm-7.0 /etc/alternatives/php-fpm"
	action :run
	not_if { ::File.symlink?('/etc/alternatives/php-fpm') }
end

execute 'set php-fpm-init to php7' do
	command "ln -s /etc/rc.d/init.d/php-fpm-7.0 /etc/alternatives/php-fpm-init"
	action :run
	not_if { ::File.symlink?('/etc/alternatives/php-fpm-init') }
end

execute 'configure php7' do
	command "service php-fpm restart"
	action :run
	notifies :run, 'execute[ajenti_restart]', :immediately
	only_if "etc/alternatives/php-fpm --version | grep PHP\ 5"
end

service 'ajenti' do
    action [:enable, :start]
end

execute 'ajenti_v_apply' do
	command "ajenti-ipc v apply"
	action :nothing
end

execute 'ajenti_restart' do
	command 'service ajenti restart'
	notifies :run, 'execute[ajenti_v_apply]', :immediately
	action :nothing
end

execute 'import first website' do
	command "ajenti-ipc v import /home/ec2-user/rt/website.json"
	action :run
	notifies :run, 'execute[rm_ajenti_website_json]', :immediately
	notifies :run, 'execute[ajenti_v_apply]', :immediately
	only_if { ::File.exists?('/home/ec2-user/rt/website.json')}
end

execute 'rm_ajenti_website_json' do
	command "rm /home/ec2-user/rt/website.json"
	action :nothing
	only_if { ::File.exists?('/home/ec2-user/rt/website.json')}
end
