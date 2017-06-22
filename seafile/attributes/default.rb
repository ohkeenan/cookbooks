#
# Cookbook Name:: seafile
#
# Copyright 2017, KEENAN VERBRUGGE
#
# All rights reserved - Do Not Redistribute
#

default['seafile']['version'] = '6.0.9'
default['seafile']['arch'] = 'x86-64'

default['seafile']['user'] = 'seafile'
default['seafile']['path'] = '/srv/seafile'

default['seafile']['use_ssl'] = true
default['seafile']['client_key'] = '/etc/ssl/cacert.pem'
default['seafile']['private_key'] = '/etc/ssl/privkey.pem'

default['seafile']['fqdn'] = 'thkeenan.com'
default['seafile']['subdomain'] = 'seafile'
default['seafile']['server_name'] = node.name

# nginx
default['seafile']['fastcgi_port'] = '9000'

default['seafile']['seahub_port'] = '9082'

default['seafile']['use_vault'] = true
default['seafile']['vault'] = 'credentials' #credentials
default['seafile']['vaultitem'] = node.name

default['seafile']['data'] = {
  'users' => [ 'ec2-user' ]
}
