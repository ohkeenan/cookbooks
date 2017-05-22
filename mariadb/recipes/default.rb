#                                                                                                                     
# Cookbook Name:: mariadb
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe 'yum'

yum_repository 'mariadb' do
    description 'MariaDB Repository'
    baseurl     "http://yum.mariadb.org/5.5/centos6-amd64"
	gpgkey      'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB'
end

execute "update" do
    command "yum update -y"
    action :run
end

package ["MariaDB-server","MariaDB-client"]

