#
# Cookbook Name:: wrapper-mariadb
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package ["MariaDB-client","MariaDB-server","MariaDB-devel"]

mysql2_chef_gem_mariadb 'default' do
  action :install
end

include_recipe 'chef-vault'
vault = chef_vault_item(node[:s3fs][:vault], node.name)

if node[:platform] == 'amazon'
  yum_repository 'mariadb' do
    description "MariaDB"
    baseurl "http://yum.mariadb.org/5.5/centos6-amd64"
    gpgkey 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
    action :create
  end
end

service 'mysql' do
  action [:enable, :start]
end

mysql_connection_info = {
  :host       => '127.0.0.1',
  :username   => 'root'
}

mysql_database 'secure_installation_delete_empty_user' do
  connection mysql_connection_info
  database_name 'mysql'
  sql 'DELETE FROM mysql.user WHERE User="";'
  action :query
  only_if 'mysql -e "SHOW DATABASES"'
end

mysql_database 'secure_installation_delete_external_root' do
  connection mysql_connection_info
  database_name 'mysql'
  sql 'DELETE FROM mysql.user WHERE User="root" AND Host NOT IN ("localhost","127.0.0.1","::1");'
  action :query
  only_if 'mysql -e "SHOW DATABASES"'
end

mysql_database 'secure_installation_drop_test' do
  connection mysql_connection_info
  database_name 'mysql'
  sql 'DROP DATABASE IF EXISTS test;'
  action :query
  only_if 'mysql -e "SHOW DATABASES"'
end

mysql_database 'secure_installation_delete_test' do
  connection mysql_connection_info
  database_name 'mysql'
  sql 'DELETE FROM mysql.db WHERE Db="test" OR Db="test\\\\_%";'
  action :query
  only_if 'mysql -e "SHOW DATABASES"'
end

mysql_database 'secure_installation_root_user' do
  connection mysql_connection_info
  database_name 'mysql'
  sql "UPDATE mysql.user SET Password=PASSWORD('#{vault[:sql_root]}') WHERE User='root';"
  action :query
  only_if 'mysql -e "SHOW DATABASES"'
end

mysql_database 'secure_installation_flush_privs' do
  connection mysql_connection_info
  database_name 'mysql'
  sql 'FLUSH PRIVILEGES;'
  action :query
  only_if 'mysql -e "SHOW DATABASES"'
end
