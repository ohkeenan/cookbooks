name             'ajenti1'
maintainer       'Keenan Verbrugge'
maintainer_email 'hello@ohkeenan.com'
license          'All rights reserved'
description      'Installs/Configures ajenti1'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'amazon'

depends 'chef-vault'
depends 'mariadb'
depends 'mysql'
depends 'mysql2_chef_gem'
depends 'poise-python'
depends 'database'
