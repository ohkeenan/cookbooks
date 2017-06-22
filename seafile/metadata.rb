name             'seafile'
maintainer       'KEENAN VERBRUGGE'
maintainer_email 'hello@ohkeenan.com'
license          'All rights reserved'
description      'Installs/Configures seafile'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'amazon'

depends 'chef-vault'
depends 'poise-python'
