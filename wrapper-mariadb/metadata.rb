name             'wrapper-mariadb'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures wrapper-mariadb'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'chef-vault'
depends 'mariadb'
depends 'mysql'
depends 'mysql2_chef_gem'
depends 'poise-python'
depends 'database'
