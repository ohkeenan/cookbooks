#
# Cookbook Name:: seafile
# Recipe:: default
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'chef-vault'

package ['python-imaging','MySQL-python','python-memcached','python-ldap','python-urllib3']

python_execute 'install MySQL-python' do
	action :run
	command "-m pip install MySQL-python"
	not_if "python -m pip list 2>/dev/null|grep MySQL"
end

python_execute 'install python-memcached' do
	action :run
	command "-m pip install python-memcached"
	not_if "python -m pip list 2>/dev/null|grep memcached"
end

python_execute 'install python-ldap' do
	action :run
	command "-m pip install python-ldap"
	not_if "python -m pip list 2>/dev/null|grep ldap"
end

python_execute 'install python-urllib3' do
	action :run
	command "-m pip install python-urllib3"
	not_if "python -m pip list 2>/dev/null|grep urllib3"
end

user node[:seafile][:user] do
  action :create
end

directory node[:seafile][:path] do
  owner node[:seafile][:user]
  group node[:seafile][:user]
  mode '0755'
	recursive true

  action :create
end

bash "extract seafile" do
  cwd node[:seafile][:path]
  code "
    wget https://download.seadrive.org/seafile-server_#{node[:seafile][:version]}_#{node[:seafile][:arch]}.tar.gz
    tar -xzf seafile-server_*
    mkdir installed
    mv seafile-server_* installed
    cd seafile-server-*
  "
  user node[:seafile][:user]
	group node[:seafile][:user]
  not_if { File.exists?("#{node[:seafile][:path]}/installed/seafile-server_#{node[:seafile][:version]}_#{node[:seafile][:arch]}.tar.gz") }
end

template '/etc/init.d/seafile-server' do
  source 'seafile_init.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

if node['seafile']['use_vault']
  vault = chef_vault_item(node[:seafile][:vault], node[:seafile][:vaultitem])

	node.default["seafile"]["admin"]["email"] = vault[:seafile_admin]

  expect_script 'install seafile' do
    cwd "#{node[:seafile][:path]}/seafile-server-#{node[:seafile][:version]}"
    code <<-EOH
      spawn #{node[:seafile][:path]}/seafile-server-#{node[:seafile][:version]}/setup-seafile-mysql.sh
      set timeout 30
      expect {
        -regexp "Press ENTER to continue.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "server name.*" {
          exp_send "#{node[:seafile][:server_name]}\r"
          exp_continue
        }
        -regexp "This server's ip or domain.*" {
          exp_send "#{vault[:domain]}\r"
          exp_continue
        }
        -regexp "Where do you want to put your seafile data?.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "Which port do you want to use for the seafile fileserver?.*" {
          exp_send "#{node[:seafile][:seahub_port]}\r"
          exp_continue
        }
        -regexp "Please choose a way to initialize seafile databases:.*" {
          exp_send "1\r"
          exp_continue
        }
        -regexp "What is the host of mysql server?.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "What is the port of mysql server?.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "What is the password of the mysql root user?.*" {
          exp_send "#{vault[:sql_root]}\r"
          exp_continue
        }
        -regexp "Enter the name for mysql user of seafile.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "Enter the password for mysql user.*" {
          exp_send "#{vault[:sql_seafile]}\r"
          exp_continue
        }
        -regexp "Enter the database name for ccnet-server.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "Enter the database name for seafile-server:.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "Enter the database name for seahub:.*" {
          exp_send "\r"
          exp_continue
        }
        -regexp "Press ENTER to continue.*" {
          exp_send "\r"
          exp_continue
        }
        eof
      }
    EOH
    user 'seafile'
    group 'seafile'
		notifies :run, 'ruby_block[correct_service_url]', :immediately
		notifies :run, 'ruby_block[correct_seahub_settings]', :immediately
		notifies :run, 'execute[first_run_seafile]', :immediately
		notifies :run, 'ruby_block[seafile_set_admin]', :immediately
		notifies :run, 'execute[first_run_seahub]', :immediately
		notifies :run, 'ruby_block[replace_old_check_init_admin]', :immediately

    not_if { Dir.exists?("#{node[:seafile][:path]}/conf") }
  end

	execute 'first_run_seafile' do
		command './seafile.sh start'
		cwd "#{node[:seafile][:path]}/seafile-server-latest"
		user 'seafile'
    group 'seafile'

	  action :nothing
	end

  ruby_block 'correct_service_url' do
    block do
      fe = Chef::Util::FileEdit.new("#{node[:seafile][:path]}/conf/ccnet.conf")
      fe.search_file_replace_line(/SERVICE_URL =/,
        "SERVICE_URL = https://#{node[:seafile][:subdomain]}.#{vault[:domain]}")
      fe.write_file
    end
		only_if { File.exists?("#{node[:seafile][:path]}/conf/ccnet.conf") }
    #not_if File.open("#{node[:seafile][:path]}/conf/ccnet.conf").grep(/"#{node[:seafile][:subdomain]}.#{node[:seafile][:fqdn]}"/)
		action :nothing
  end

	ruby_block 'seafile_set_admin' do
    block do
      fe = Chef::Util::FileEdit.new("#{node[:seafile][:path]}/seafile-server-latest/check_init_admin.py")
      fe.search_file_replace(/= ask_admin_email\(\)/,
        "= \"#{vault[:seafile_admin]}\"")
				fe.search_file_replace(/= ask_admin_password\(\)/,
	        "= \"#{vault[:seafile_pass]}\"")
      fe.write_file
    end
		only_if { File.exists?("#{node[:seafile][:path]}/seafile-server-latest/check_init_admin.py") }

		action :nothing
  end

	ruby_block 'replace_old_check_init_admin' do
		block do
			File.rename("#{node[:seafile][:path]}/seafile-server-latest/check_init_admin.py.old", "#{node[:seafile][:path]}/seafile-server-latest/check_init_admin.py")
		end

		action :nothing
	end

  ruby_block 'correct_seahub_settings' do
    block do
      fe = Chef::Util::FileEdit.new("#{node[:seafile][:path]}/conf/seahub_settings.py")
      fe.insert_line_if_no_match(/"FILE_SERVER_ROOT = 'https:\/\/#{node[:seafile][:subdomain]}.#{vault[:domain]}\/seafhttp'"/,
                                 "FILE_SERVER_ROOT = 'https:\/\/#{node[:seafile][:subdomain]}.#{vault[:domain]}\/seafhttp'")
      fe.write_file
    end
		only_if { File.exists?("#{node[:seafile][:path]}/conf/seahub_settings.py") }

		action :nothing
  end

	execute 'first_run_seahub' do
		command "./seahub.sh start-fastcgi #{node[:seafile][:fastcgi_port]}"
		cwd "#{node[:seafile][:path]}/seafile-server-latest"
		user 'seafile'
    group 'seafile'

	  action :nothing
	end



  # finish this below
  # add service config stuff
end
