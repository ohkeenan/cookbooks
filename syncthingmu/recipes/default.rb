#
# Cookbook Name:: syncthingmu
# Recipe:: default
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#

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
  only_if 'go version|cut -f3 -d" "|tr -d "go"' >= Gem::Version.new(node[:syncthingmu][:go_version])
  not_if { File.exists?("/usr/bin/syncthing") }
end
