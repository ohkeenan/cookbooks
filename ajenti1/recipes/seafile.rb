#
# Cookbook Name:: ajenti1
# Recipe:: seafile
#
# Copyright 2017, Keenan Verbrugge
#
#

bash 'ajenti_ipc_import_seafile' do
  command 'ajenti-ipc v import /root/seafile.json'
  action :nothing
  notifies :run, 'execute[ajenti_v_apply]', :delayed
end

template '/root/seafile.json' do
  source 'ajenti_seafile.json.erb'
  notifies :run, 'bash[ajenti_ipc_import_seafile]', :delayed
end
