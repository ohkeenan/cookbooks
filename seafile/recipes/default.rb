#
# Cookbook Name:: seafile
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

packages ['python-imaging','MySQL-python','python-memcached','python-ldap','python-urllib3']

user node[:seafile][:user] do
  action :create
end

directory node[:seafile][:path] do
  owner node[:seafile][:user]
  group node[:seafile][:user]
  mode '0750'
  action :create
end

bash "extract seafile" do
  cwd node[:seafile][:path]
  code "
    wget https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_#{node[:seafile][:version]}_#{node[:seafile][:arch]}.tar.gz
    tar -xzf seafile-server_*
    mkdir installed
    mv seafile-server_* installed
    cd seafile-server-*
  "
  not_if { File.exists?("#{node[:seafile][:path]}/installed/seafile-server_#{node[:seafile][:version]}_#{node[:seafile][:arch]}.tar.gz") }
end

expect_script 'install seafile' do
  cwd "#{node[:seafile][:path]}/seafile-server-#{node[:seafile][:version]}"
  code <<-EOH
    spawn test.sh
    set timeout 30
    expect {
      -regexp "Would you like to delete your all files (yes/no)?.*" {
        exp_send "no\r"
        exp_continue
      }
      eof
    }
  EOH
  user 'root'
  group 'root'
end
