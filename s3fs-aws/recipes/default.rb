#
# Cookbook Name:: s3fs-aws
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package ["fuse","git"]

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

