#
# Cookbook Name:: ajenti1
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'chef-vault'
vault = chef_vault_item(node[:s3fs][:vault], node[:s3fs][:vaultitem])


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

service 'ajenti' do
    action [:enable, :start]
end

service 'php-fpm' do
	action :stop
	only_if "ls -l /etc/alternatives/php-fpm | grep php-fpm-5"
end

link '/etc/alternatives/php' do
	to '/usr/bin/php7'
end

link '/etc/alternatives/php-fpm' do
	to '/usr/sbin/php-fpm-7.0'
	notifies :run, 'execute[ajenti_restart]', :immediately
	notifies :run, 'execute[ajenti_v_apply]', :immediately
end

link '/etc/alternatives/php-fpm-init' do
	to '/etc/rc.d/init.d/php-fpm-7.0'
end

service 'nginx' do
	action [:enable, :start]
end

service 'php-fpm' do
	action [:enable, :start]
end

execute 'ajenti_v_apply' do
	command "ajenti-ipc v apply"
	retries 1
	retry_delay 4
	action :nothing
end

execute 'ajenti_restart' do
	command 'service ajenti restart'
	action :nothing
end

directory "/srv/#{vault[:domain]}" do
	owner 'www-data'
	group 'www-data'
	mode '0750'
	action :create
end

template "/srv/#{vault[:domain]}/index.html" do
  source 'index.erb'
  owner 'www-data'
  group 'www-data'
  mode '0755'
	action :create_if_missing
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
