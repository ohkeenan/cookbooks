#
# Cookbook Name:: ajenti1
# Recipe:: nextcloud
#
# Copyright 2017, Keenan Verbrugge
#
#

bash 'import first seafile' do
    code "ajenti-ipc v import /home/ec2-user/rt/seafile.json && \
						rm /home/ec2-user/rt/seafile.json && \
						ajenti-ipc v apply"
    action :run
    only_if { ::File.exists?('/home/ec2-user/rt/seafile.json')}
end
