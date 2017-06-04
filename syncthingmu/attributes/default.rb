case node["platform"]

when "amazon"
  default["syncthingmu"]["packages"] = %w{golang}
end

# Going to assume this is true unless you make a pkg
default["syncthingmu"]["build_from_source"] = true
default["syncthingmu"]["go_version"] = "1.7.5"

default["syncthingmu"]["storage_dir"] = '/mnt'
default["syncthingmu"]["multi_user"] = false

default["syncthingmu"]["version"] = ''
default["syncthingmu"]["options"] = ''

default["syncthingmu"]["data_from_bag"] = false

default["syncthingmu"]["use_vault"] = false
default["syncthingmu"]["vault"] = "" #credentials
default["syncthingmu"]["vaultitem"] = "" #node.name

default["syncthingmu"]["data"] = {
  "users" => [ "ec2-user" ]
}
