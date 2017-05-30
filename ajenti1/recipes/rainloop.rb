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

execute "chown rainloop" do
	command "chown -R www-data:www-data /srv/rainloop"
	action :run
	not_if "ls -l /srv/rainloop | grep -q www-data"
end

bash 'import first rainloop' do
    code "ajenti-ipc v import /home/ec2-user/rt/rainloop.json && \
						rm /home/ec2-user/rt/rainloop.json && \
						ajenti-ipc v apply"
    action :run
    only_if { ::File.exists?('/home/ec2-user/rt/rainloop.json')}
end