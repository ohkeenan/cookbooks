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
# default['ajenti1']['user'] = 'ajenti1' #?maybe necessary to set user for nginx/www-data user across multiple platforms

default['ajenti1']['website_root'] = '/srv/'
default['ajenti1']['website_ssl_key'] = '/etc/ssl/certs/nginx-selfsigned.key'
default['ajenti1']['website_ssl_cert'] = '/etc/ssl/certs/nginx-selfsigned.pem'

default['ajenti1']['seafile_subdomain'] = 'seafile'
default['ajenti1']['seafile_root'] = '/srv/seafile'
default['ajenti1']['seafile_ssl_key'] = '/etc/ssl/certs/nginx-selfsigned.key'
default['ajenti1']['seafile_ssl_cert'] = '/etc/ssl/certs/nginx-selfsigned.pem'


default['ajenti1']['nextcloud_subdomain'] = 'cloud'
default['ajenti1']['nextcloud_root'] = '/srv/nextcloud'
default['ajenti1']['nextcloud_ssl_key'] = '/etc/ssl/certs/nginx-selfsigned.key'
default['ajenti1']['nextcloud_ssl_cert'] = '/etc/ssl/certs/nginx-selfsigned.pem'


default['ajenti1']['rainloop_subdomain'] = 'rainloop'
default['ajenti1']['rainloop_root'] = '/srv/rainloop'
default['ajenti1']['rainloop_ssl_key'] = '/etc/ssl/certs/nginx-selfsigned.key'
default['ajenti1']['rainloop_ssl_cert'] = '/etc/ssl/certs/nginx-selfsigned.pem'



default['ajenti1']['use_ssl'] = true
default['ajenti1']['selfsign'] = true
default['ajenti1']['key_dir'] = '/etc/ssl/certs'

# see https://github.com/chef-cookbooks/openssl
default['ajenti1']['ssl_commonname'] = node.name
default['ajenti1']['ssl_org'] = node.name
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
default['ajenti1']['use_vault'] = true
default['ajenti1']['vault'] = 'credentials' #credentials
default['ajenti1']['vaultitem'] = node.name
#
# default['ajenti1']['data'] = {
#   'users' => [ 'ec2-user' ]
# }
