#
# Cookbook Name:: ajenti1
# Recipe:: rainloop
#
# Copyright 2017, Keenan Verbrugge
#
#

package ["bsdtar"]

directory "/srv/rainloop" do
	owner 'www-data'
	group 'www-data'
	mode '0750'
	action :create
end

execute "download rainloop" do
	command "wget -qO- https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip | bsdtar -xf- -C /srv/rainloop/"
	not_if { ::Dir.exists?("/srv/rainloop/data")}
end
