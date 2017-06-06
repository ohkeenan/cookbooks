#
# Cookbook Name:: seafile
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#



default["seafile"]["version"] = "6.0.9"
default["seafile"]["arch"] = "x86-64"

default["seafile"]["user"] = "seafile"
default["seafile"]["path"] = "/srv/seafile"

default["seafile"]["use_vault"] = false
default["seafile"]["vault"] = "" #credentials
default["seafile"]["vaultitem"] = "" #node.name

default["seafile"]["data"] = {
  "users" => [ "ec2-user" ]
}
