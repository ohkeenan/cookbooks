name             'expect'
maintainer       'Radoslaw Jaros'
maintainer_email 'jaros_radek@op.pl'
license          'Apache 2.0'
description      'Installs/Configures expect package'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'
source_url       'https://github.com/rjaros87/chef-expect'
issues_url       'https://github.com/rjaros87/chef-expect/issues'

%w(
  debian
  ubuntu
  centos
  redhat
  fedora
  windows
  mac_os_x
).each do |os|
  supports os
end

chef_version '>= 12.11'

depends 'windows', '>= 1.44.1'
depends 'homebrew', '>= 2.1.0'
depends 'cygwin', '~> 0.7.0'
