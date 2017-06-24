#
# Cookbook Name:: ajenti1
# Recipe:: seafile
#
# Copyright 2017, Keenan Verbrugge
#
#
include_recipe 'chef-vault'
vault = chef_vault_item(node[:ajenti1][:vault], node[:ajenti1][:vaultitem])

execute 'ajenti_ipc_import_seafile' do
  command 'ajenti-ipc v import /root/seafile.json'
  action :nothing
  notifies :run, 'execute[ajenti_v_apply]', :delayed
end

template '/root/seafile.json' do
  source 'ajenti_seafile.json.erb'
  variables( {:domain => vault[:domain]})
  notifies :run, 'execute[ajenti_ipc_import_seafile]', :delayed
  not_if { File.exist?("/etc/nginx/conf.d/seafile.conf" )}
end
