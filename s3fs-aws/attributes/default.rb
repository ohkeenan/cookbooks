default["s3fs"]["build_from_source"] = true                                                                                                           

case node["platform"]

when "amazon"
  default["s3fs"]["packages"] = %w{gcc libstdc++-devel gcc-c++ curl-devel libxml2-devel openssl-devel mailcap make fuse fuse-devel}
  default["fuse"]["version"] ="2.9.2"
end

default["s3fs"]["mount_root"] = '/mnt'
default["s3fs"]["multi_user"] = false
default["s3fs"]["version"] = "1.79"
default["s3fs"]["options"] = {
	'allow_other,use_cache=/tmp,iam_role='
	node['s3fs']['instance_profile']
}

default["s3fs"]["data_from_bag"] = false

default["s3fs"]["data"] = {
  "buckets" =>  ["nw-rt"]
}      
