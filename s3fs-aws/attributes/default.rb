#default["s3fs"]["build_from_source"] = true

case node["platform"]

when "amazon"
  default["s3fs"]["packages"] = %w{gcc libstdc++-devel gcc-c++ curl-devel libxml2-devel openssl-devel mailcap make fuse fuse-devel}
  default["fuse"]["version"] ="2.9.2"
end

default["s3fs"]["mount_root"] = '/mnt'
default["s3fs"]["multi_user"] = false
default["s3fs"]["version"] = "1.82"
default["s3fs"]["options"] = '_netdev,allow_other,use_cache=/tmp'

default["s3fs"]["data_from_bag"] = false
default["s3fs"]["vault"] = "credentials"
default["s3fs"]["vaultitem"] = node.name


default["s3fs"]["data"] = {
  "buckets" =>  [""]
}
