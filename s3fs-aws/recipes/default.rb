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

ruby_block "get iam profile" do
	block do
    #tricky way to load this Chef::Mixin::ShellOut utilities
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    command = 'curl http://169.254.169.254/latest/meta-data/iam/info --silent | grep instance-profile | cut -d/ -f2 | tr -d \'",\''
    command_out = shell_out(command)
    node.default['instance_profile'] = command_out.stdout
    end
    action :create
end 

ruby_block "get user bucket" do
    block do
        #tricky way to load this Chef::Mixin::ShellOut utilities
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        command = 'curl http://169.254.169.254/latest/meta-data/iam/info --silent | grep instance-profile | cut -d- -f5 | tr -d \'",\' |md5sum'
        command_out = shell_out(command)
        node.default['user_bucket'] = command_out.stdout
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
    device "s3fs##{bucket[:name]}"
    fstype "fuse"
    options node['s3fs']['options','user_bucket','instance_profile'] #this will bork
    dump 0
    pass 0
    action [:mount, :enable]
    not_if "grep -qs '#{bucket[:path]} ' /proc/mounts"
  end
end
