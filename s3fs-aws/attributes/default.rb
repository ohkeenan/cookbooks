default["s3fs"]["build_from_source"] = true                                                                                                           

case node["platform"]

when "amazon"
  default["s3fs"]["packages"] = %w{gcc libstdc++-devel gcc-c++ curl-devel libxml2-devel openssl-devel mailcap make fuse fuse-devel}
  default["fuse"]["version"] ="2.9.2"

ruby_block "get iam role" do
    block do
    #tricky way to load this Chef::Mixin::ShellOut utilities
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    command = 'curl http://169.254.169.254/latest/meta-data/iam/info --silent | grep instance-profile | cut -d/ -f2 | tr -d "\","'
    command_out = shell_out(command)
    node.default[:instance_profile] = command_out.stdout                                                                                              
    end 
    action :create
end 

ruby_block "get user bucket" do
    block do
        #tricky way to load this Chef::Mixin::ShellOut utilities
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
        command = 'curl http://169.254.169.254/latest/meta-data/iam/info --silent | grep instance-profile | cut -d- -f5 | tr -d "\"," |md5sum |cut -d " " -f1'
        command_out = shell_out(command)
        node.default[:user_bucket] = command_out.stdout
    end 
    action :create
end

end

default["s3fs"]["mount_root"] = '/mnt'
default["s3fs"]["multi_user"] = false
default["s3fs"]["version"] = "1.79"
default["s3fs"]["options"] = '_netdev,allow_other,use_cache=/tmp'

default["s3fs"]["data_from_bag"] = false

default["s3fs"]["data"] = {
  "buckets" =>  ["nw-rt"]
}      
