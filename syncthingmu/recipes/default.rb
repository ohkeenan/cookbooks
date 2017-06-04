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
  # This should output "go version go1.75" or higher.
  only_if "go version |grep #{node[:syncthingmu]}"

# Go is particular about file locations; use this path unless you know very
# well what you're doing.
$ mkdir -p ~/src/github.com/syncthing
$ cd ~/src/github.com/syncthing
# Note that if you are building from a source code archive, you need to
# rename the directory from syncthing-XX.YY.ZZ to syncthing
$ git clone https://github.com/syncthing/syncthing

# Now we have the source. Time to build!
$ cd syncthing

# You should be inside ~/src/github.com/syncthing/syncthing right now.
$ go run build.go
