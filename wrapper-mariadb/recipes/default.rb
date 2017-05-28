#
# Cookbook Name:: wrapper-mariadb
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
if node[:platform] == 'amazon'
  yum_repository 'mariadb' do
    description "MariaDB"
    baseurl "http://yum.mariadb.org/5.5/centos6-amd64"
    gpgkey 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
    action :create
  end	
end
package ["MariaDB-client","MariaDB-server","MariaDB-devel"]

service 'mysql' do
  action [:enable, :start]
end
