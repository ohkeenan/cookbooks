#
# Cookbook Name:: ajenti1
# Recipe:: database
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'chef-vault'

mysql2_chef_gem_mariadb 'default' do
  action :install
end

vault = chef_vault_item(:credentials, node.name)

mysql_connection_info = {
  :host       => '127.0.0.1',
  :username   => 'root',
  :password   => vault['sql_root']
}

mysql_database 'nextcloud' do
  connection mysql_connection_info
  action :create
end

mysql_database_user 'nextcloud' do
  connection mysql_connection_info
  password vault['sql_nextcloud']
  database_name 'nextcloud'
  host '127.0.0.1'
  privileges [:all]
  action [:create, :grant]
end

execute 'install nextcloud' do
	command "php /srv/nextcloud/occ maintenance:install --database mysql \
	        --database-name nextcloud \
	        --database-user nextcloud \
	        --database-pass #{vault[:sql_root]} \
	        --admin-pass #{vault[:cloud_admin]} \
	        --admin-user admin \
	        -v"
	user 'www-data'
  not_if 'sudo -u www-data php /srv/nextcloud/occ status | grep true'
end
