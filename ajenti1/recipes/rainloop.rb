#
# Cookbook Name:: ajenti1
# Recipe:: rainloop
#
# Copyright 2017, Keenan Verbrugge
#
#
include_recipe 'chef-vault'
vault = chef_vault_item(node[:ajenti1][:vault], node[:ajenti1][:vaultitem])


package ["bsdtar"]

directory "/srv/rainloop" do
	owner 'www-data'
	group 'www-data'
	mode '0750'
	action :create
end

execute "download rainloop" do
	command "wget -qO- https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip | bsdtar -xf- -C /srv/rainloop/"
	notifies :run, 'execute[chown_rainloop]', :immediately
	notifies :run, 'execute[chmod_rainloop]', :immediately
	not_if { ::Dir.exists?("/srv/rainloop/data")}
end

execute "chown_rainloop" do
	command "chown -R www-data:www-data /srv/rainloop"
	action :nothing
end

execute "chmod_rainloop" do
	command "chmod 0750 -R /srv/rainloop"
	action :nothing
end

execute 'ajenti_ipc_import_rainloop' do
  command 'ajenti-ipc v import /root/rainloop.json'
  action :nothing
  notifies :run, 'execute[ajenti_v_apply]', :delayed
end

template '/root/rainloop.json' do
  source 'ajenti_rainloop.json.erb'
	variables( {:domain => vault[:domain]})
  notifies :run, 'execute[ajenti_ipc_import_rainloop]', :delayed
	not_if { File.exist?("/etc/nginx/conf.d/rainloop.conf" )}
end
