#
# Cookbook Name:: s3fs-aws
# Recipe:: default
#
# Copyright 2017, Keenan Verbrugge
#
# All rights reserved - Do Not Redistribute
#

node['s3fs']['packages'].each do |pkg|
  package pkg 
end

remote_file "#{Chef::Config[:file_cache_path]}/s3fs-fuse-#{ node['s3fs']['version'] }.tar.gz" do
  	source "https://github.com/s3fs-fuse/s3fs-fuse/archive/v#{ node['s3fs']['version'] }.tar.gz"                                                        
  	mode 0644
  	action :create_if_missing
end

bash "install s3fs" do
  	cwd Chef::Config[:file_cache_path]
  	code "
    	export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig
    	tar zxvf s3fs-fuse-#{ node['s3fs']['version'] }.tar.gz
    	cd s3fs-fuse-#{ node['s3fs']['version'] }
    	./autogen.sh
    	./configure --prefix=/usr
    	make
    	make install
 	"
  	not_if { File.exists?("/usr/bin/s3fs") }
end

ruby_block "get iam role" do
	block do
    #tricky way to load this Chef::Mixin::ShellOut utilities
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    command = 'curl http://169.254.169.254/latest/meta-data/iam/info --silent | grep instance-profile | cut -d/ -f2 | tr -d "\","'
    command_out = shell_out(command)
    node.default[:s3fs][:instance_profile] = command_out.stdout
    end
    action :create
end 

ruby_block "get user bucket" do
    block do
        #tricky way to load this Chef::Mixin::ShellOut utilities
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        command = 'curl http://169.254.169.254/latest/meta-data/iam/info --silent | grep instance-profile | cut -d- -f5 | tr -d "\"," |md5sum |cut -d " " -f1'
        command_out = shell_out(command)
        node.default[:s3fs][:user_bucket] = command_out.stdout
    end
    action :create
end

def retrieve_s3_buckets(s3_data)
  buckets = []

  s3_data['buckets'].each do |bucket|
    bucket = Bucket.new(bucket, node)
    buckets << {
      :name => bucket.name,
      :path => bucket.path,
      :access_key => ((s3_data.include?('access_key_id')) ? s3_data['access_key_id'] : ''),
      :secret_key => ((s3_data.include?('secret_access_key')) ? s3_data['secret_access_key'] : '') 
    }   
  end 

  buckets
end

class Bucket
  attr_reader :name
  attr_reader :path
  attr_reader :instance_profile
  attr_reader :user_bucket
  def initialize bucket, node
    if bucket.is_a? String
      @name = bucket
      @path = File.join(node['s3fs']['mount_root'], @name)
    elsif bucket.is_a? Hash
      @name = bucket['name']
      @path = bucket['path']
    else
      @name = ""
      @path = ""
    end
  end
end

if node['s3fs']['multi_user']
  buckets = []
  node['s3fs']['data'].each do |item|
    buckets += retrieve_s3_buckets(item)
  end
elsif node['s3fs']['data_from_bag']
  s3_bag = data_bag_item(node['s3fs']['data_bag']['name'], node['s3fs']['data_bag']['item'])
  if s3_bag['access_key_id'].include? 'encrypted_data'
    s3_bag = Chef::EncryptedDataBagItem.load(node['s3fs']['data_bag']['name'], node['s3fs']['data_bag']['item'])
  end

  buckets = retrieve_s3_buckets({"buckets" => s3_bag['buckets'], "access_key_id" => s3_bag['access_key_id'], "secret_access_key" => s3_bag['secret_access_key']})
else
  buckets = retrieve_s3_buckets(node['s3fs']['data'])
end

buckets.each do |bucket|
  directory bucket[:path] do
    owner     "root"
    group     "root"
    mode      0777
    recursive true
    not_if do
      File.exists?(bucket[:path])
    end
  end
		mount bucket[:path] do
			device "s3fs##{bucket[:name]}:/users/#{node[:user_bucket]}"
			fstype "fuse"
			options "#{node[:s3fs][:options]},iam_role=#{node[:instance_profile]}"
			dump 0
			pass 0
			action [:mount, :enable]
			#not_if "grep -qs '#{bucket[:path]}/#{node[:user_bucket]} ' /proc/mounts"
		end
end
