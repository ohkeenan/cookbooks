#
# Cookbook Name:: ajenti1
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#

# default['ajenti1']['version'] = ''
# default['ajenti1']['arch'] = 'x86-64'
#
# default['ajenti1']['user'] = 'ajenti1'
# default['ajenti1']['path'] = '/srv/ajenti1'

default['ajenti1']['use_ssl'] = true
default['ajenti1']['selfsign'] = true
default['ajenti1']['key_dir'] = '/etc/ssl/'

# see https://github.com/chef-cookbooks/openssl
default['ajenti1']['ssl_commonname'] = ""
default['ajenti1']['ssl_org'] = ""
default['ajenti1']['ssl_orgunit'] = ""
default['ajenti1']['ssl_country'] = ""

#
# default['ajenti1']['fqdn'] = 'thkeenan.com'
# default['ajenti1']['subdomain'] = 'ajenti1'
# default['ajenti1']['server_name'] = node.name
#
# # nginx
# default['ajenti1']['fastcgi_port'] = '9000'
#
# default['ajenti1']['seahub_port'] = '9082'
#
# default['ajenti1']['use_vault'] = true
# default['ajenti1']['vault'] = 'credentials' #credentials
# default['ajenti1']['vaultitem'] = node.name
#
# default['ajenti1']['data'] = {
#   'users' => [ 'ec2-user' ]
# }
