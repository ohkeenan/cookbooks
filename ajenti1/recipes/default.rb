#
# Cookbook Name:: ajenti1
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'chef-vault'
vault = chef_vault_item(node[:ajenti1][:vault], node[:ajenti1][:vaultitem])


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

execute 'ajenti_ipc_import_website' do
  command "ajenti-ipc v import /root/#{node.name}.json"
  action :nothing
  notifies :run, 'execute[ajenti_v_apply]', :delayed
end

template "/root/#{node.name}.json" do
  source 'ajenti_website.json.erb'
	variables(:domain => vault[:domain],
							:root_dir => "#{node['ajenti1']['website_root']}#{vault[:domain]}")
  notifies :run, 'execute[ajenti_ipc_import_website]', :delayed
	not_if { File.exist?("/etc/nginx/conf.d/#{node.name}.conf" )}
end


if node['ajenti1']['use_ssl']
	if node['ajenti1']['selfsign']
		openssl_x509 "#{node[:ajenti1][:key_dir]}/nginx-selfsigned.pem" do
		  common_name node['ajenti1']['ssl_commonname']
		  org node['ajenti1']['ssl_org']
		  org_unit node['ajenti1']['ssl_orgunit']
		  country node['ajenti1']['ssl_country']
			not_if { ::File.exists?("#{node[:ajenti1][:key_dir]}/nginx-selfsigned.pem")}
		end
	end


end
