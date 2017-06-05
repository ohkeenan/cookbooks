#
# Cookbook Name:: syncthingmu
# Recipe:: default
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'chef-vault'

node['syncthingmu']['packages'].each do |pkg|
  package pkg
end

if node['syncthingmu']['build_from_source'] == true
  bash "install syncthing" do
    cwd Chef::Config[:file_cache_path]
    code "
      mkdir -p ~/src/github.com/syncthing
      cd ~/src/github.com/syncthing
      git clone https://github.com/syncthing/syncthing.git
      cd syncthing
      go run build.go
      cp bin/* /usr/local/bin/
    "
    #only_if Gem::Version.new(`go version|cut -f3 -d" "|tr -d "go"`) >= Gem::Version.new(node[:syncthingmu][:go_version])
    not_if { File.exists?("/usr/local/bin/syncthing") }
  end
end

def retrieve_st_users(st_data)
  st_users = []

  st_data['users'].each do |st_user|
    st_user = Stuser.new(st_user, node)
    st_users << {
      :name => st_user.name
    }
  end

  st_users
end

class Stuser
  attr_reader :name

  def initialize st_user, node
    if st_user.is_a? String
      @name = st_user
    elsif st_user.is_a? Hash
      @name = st_user['name']
    else
      @name = ""
    end
  end
end

# Chef vault
if node['syncthingmu']['use_vault']
  vault = chef_vault_item(node[:syncthingmu][:vault], node[:syncthingmu][:vaultitem])
  st_users = retrieve_st_users({"users" => vault[:syncthing_users]})
else
  st_users = retrieve_st_users(node['syncthingmu']['data'])
end

template '/etc/init.d/syncthing' do
  source 'syncthing_sysvinit'
  owner 'root'
  group 'root'
  mode '0755'
end

st_users.each do |st_user|

  user st_user[:name] do
    action :create
  end
  execute "syncthing for #{st_user[:name]}" do
    command "USER=#{st_user[:name]} /etc/init.d/syncthing start"
    user st_user[:name]
    not_if "pgrep -fu #{st_user[:name]} syncthing"
  end

end
