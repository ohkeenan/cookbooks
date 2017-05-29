#
# Cookbook Name:: ajenti1
# Recipe:: database
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'chef-vault'

vault = chef_vault_item(node[:s3fs][:vault],node.name)

mysql_connection_info = {
  :host       => 'localhost',
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
  host 'localhost'
  action [:create, :grant]
end

execute 'install nextcloud' do
	command "php /srv/nextcloud/occ maintenance:install --database mysql \
	        --database-name nextcloud \
	        --database-user nextcloud \
	        --database-pass #{vault[:sql_nextcloud]} \
	        --admin-pass #{vault['cloud_admin']} \
	        --admin-user admin \
	        -v"
	user 'www-data'
  only_if 'sudo -u www-data php /srv/nextcloud/occ status | grep true'
end

execute 'install nextcloud' do
	command "php /srv/nextcloud/occ config:system:set trusted_domains 2 --value=cloud.#{vault[:domain]}"
	user 'www-data'
  not_if "sudo -u www-data php /srv/nextcloud/occ config:system:get trusted_domains | grep #{vault[:domain]}"
end

execute 'import nextcloud into ajenti' do
	command 'ajenti-ipc v import /home/ec2-user/rt/nextcloud.json && rm /home/ec2-user/rt/nextcloud.json && ajenti-ipc v apply'
	action :run
	only_if { ::File.exists?('/home/ec2-user/rt/nextcloud.json')}
end
