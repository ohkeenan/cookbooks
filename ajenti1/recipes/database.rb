#
# Cookbook Name:: ajenti1
# Recipe:: database
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'chef-vault'
vault = chef_vault_item(node[:ajenti1][:vault], node[:ajenti1][:vaultitem])

mysql_connection_info = {
  :host       => 'localhost',
  :username   => 'root',
  :password   => vault['sql_root']
}

mysql_database 'nextcloud' do
  connection mysql_connection_info
  action :create
end

mysql_database 'rainloop' do
  connection mysql_connection_info
  action :create
end

mysql_database_user 'rainloop' do
  connection mysql_connection_info
  password vault['sql_rainloop']
  database_name 'rainloop'
  host 'localhost'
  action [:create, :grant]
end

mysql_database_user 'nextcloud' do
  connection mysql_connection_info
  password vault['sql_nextcloud']
  database_name 'nextcloud'
  host 'localhost'
  action [:create, :grant]
end

bash 'install nextcloud' do
	code "php /srv/nextcloud/occ maintenance:install --database mysql \
	        --database-name nextcloud \
	        --database-user nextcloud \
	        --database-pass #{vault[:sql_nextcloud]} \
	        --admin-pass #{vault[:cloud_admin]} \
	        --admin-user admin \
	        -v"
	user "www-data"
  notifies :run, 'execute[nextcloud_add_trusted_domain]', :immediately
  not_if "sudo -u www-data php /srv/nextcloud/occ status | grep true"
end

execute 'nextcloud_add_trusted_domain' do
	command "php /srv/nextcloud/occ config:system:set trusted_domains 2 --value=cloud.#{vault[:domain]}"
	user 'www-data'
  action :nothing
end
