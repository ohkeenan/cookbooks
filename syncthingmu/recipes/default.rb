#
# Cookbook Name:: syncthingmu
# Recipe:: default
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'chef-vault'
vault = chef_vault_item(node[:s3fs][:vault], node[:s3fs][:vaultitem])

node['syncthingmu']['packages'].each do |pkg|
  package pkg
end

if node['syncthingmu']['build_from_source'] == true
  bash "install syncthing" do
    cwd Chef::Config[:file_cache_path]
    code "
      git clone https://github.com/syncthing/syncthing.git
      cd syncthing
      go run build.go
      cp bin/* /usr/bin/
    "
    #only_if Gem::Version.new(`go version|cut -f3 -d" "|tr -d "go"`) >= Gem::Version.new(node[:syncthingmu][:go_version])
    not_if { File.exists?("/usr/bin/syncthing") }
  end
end
