#
# Cookbook Name:: ajenti1
# Recipe:: nextcloud
#
# Copyright 2017, Keenan Verbrugge
#
#

include_recipe "yum"

execute "update" do
	command "yum update -y"
	action :run
end

package ["php70-ctype","php70-dom","php70-gd","php70-mbstring","php70-pdo","php70-iconv","php70-json","php70-libxml","php70-posix","php70-zip","php70-zlib","php70-curl","php70-bz2","php70-mcrypt","php70-openssl","php70-intl","php70-fileinfo","php70-exif","php70-xml","php70-imagick","php70-json"]

execute "download nextcloud" do
	command "wget -qO- https://download.nextcloud.com/server/releases/nextcloud-12.0.0.tar.bz2 | tar xj -C /srv/"
	not_if { ::Dir.exists?("/srv/nextcloud")}
end

execute "chown nextcloud" do
	command "chown -R www-data:www-data /srv/nextcloud"
	user "root"
	action :nothing #fix to run only if it's not already owned?
end

execute 'import first nextcloud' do
    command 'ajenti-ipc v import /home/ec2-user/rt/nextcloud.json && rm /home/ec2-user/rt/nextcloud.json && ajenti-ipc v apply'
    action :run
    only_if { ::File.exists?('/home/ec2-user/rt/nextcloud.json')}                                                                           
end
