#
# Cookbook Name:: ajenti1
# Recipe:: database
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'mysql'
include_recipe 'mysql2_chef_gem'
include_recipe 'chef-vault'

vault = chef_vault_item(:credentials, node.name)

node.default['sql_root']['password'] = vault['sql_root']
node.default['sql_nextcloud']['password'] = vault['sql_nextcloud']

mysql_database 'nextcloud' do
  connection(
    :host     => '127.0.0.1',
    :username => 'nextcloud',
    :password => node['sql_nextcloud']['password']
  )
  action :create
end


#mysql -uroot -e "\
#  UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root'; \
#  DELETE FROM mysql.user WHERE User=''; \
#  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
#  DROP DATABASE IF EXISTS test; \
#  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; \
#  FLUSH PRIVILEGES;"
