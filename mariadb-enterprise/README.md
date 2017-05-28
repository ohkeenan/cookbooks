MariaDB Enterprise Chef Cookbook
=====================

The MariaDB Enterprise Chef Cookbook, **mariadb-enterprise**, is a library cookbook that provides resource primitives (LWRPs) for use in recipes and a few ready to use recipes: installation, uninstallation, and starting the MariaDB Enterprise Server instance. 

**Note: For the Cookbook to be able to set up the MariaDB Enterprise Repository and download packages, you need to provide the Cookbook with your MariaDB Enterprise Download Token. You can find the token on [My Portal](https://www.mariadb.com/my_portal/). Look for the Download Token associated with the contract(s) in the Your Subscriptions section. If you do not have a MariaDB Enterprise subscription/contract, you can create an account at My Portal, sign the Evaluation Agreement, and try MariaDB Enterprise as an Evaluation User.**

Scope
-----
This cookbook supports MariaDB Enterprise Server.

Requirements
------------
- Chef 11 or higher
- Ruby 1.9 or higher (preferably from the Chef full-stack installer)
- Network access to the MariaDB Enterprise Repository

Usage
-----


Install the most-recent stable version of MariaDB Enterprise Server like this:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::install]`

Or, use the MariaDB Enterprise Chef Cookbook in a Vagrantfile:

```ruby
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "<bla-bla>/cookbooks"
      chef.provisioning_path = "/tmp/vagrant-chef/chef-solo"
      chef.json = {
        :maria => {
          version: '10.0',
          token: 'abcd-1234'
        }
      }
      chef.add_recipe "mariadb-enterprise::install"
    end
```

You can also include the MariaDB Enterprise Chef Cookbook into your own cookbook. Create a dependency on `mariadb-enterprise` in your cookbook's metadata.rb file like this:

```ruby
depends 'mariadb-enterprise', '~> 0'
```

Then, in your recipe:

```ruby
mysql_service 'foo' do
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  action [:create, :start]
end
```

The service name on the OS is `mysql-foo`. You can manually start and stop it with `service mysql-foo start` and `service mysql-foo stop`.

You can put extra configuration into the correct conf.d directory for your OS by using the `mysql_config` resource, like this:

```ruby
mysql_service 'foo' do
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  action [:create, :start]
end

mysql_config 'foo' do
  source 'my_extra_settings.erb'
  notifies :restart, 'mysql_service[foo]'
  action :create
end
```

Resources Overview
------------------
### Recipes

## install

Set up the MariaDB Enterprise Repository and install MariaDB Enterprise Server.

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::install]`

Parameters are:

- `mariadb::token` - your secret token
- `mariadb::version` - version of Maria DB

## uninstall

Removes MariaDB Enterprise Server.

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::uninstall]`

## purge

Removes MariaDB Enterprise Server, **remove all data and configurations**, and disable/remove the MariaDB Enterprise Repository.

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::purge]`

## start

Creates (but does not install) and starts MariaDB Enterprise Server.

```ruby
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "<bla-bla>/cookbooks"
      chef.provisioning_path = "/tmp/vagrant-chef/chef-solo"
      chef.json = {
        :mariadb => {
          bind_address: '127.0.0.1'
        }
      }
      chef.add_recipe "mariadb-enterprise::start"
    end
```

Parameters are:

- `mariadb::initial_root_password` - root password
- `mariadb::bind_address` - bind address
- `mariadb::port` - port
- `mariadb::socket` - socket file
- `mariadb::data_dir` - data directory, /var/lib/mysql-<instance name> by default

## install_backuper

Installs MariaDB backuper package (Percona Xtrabackup).

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::install_backuper]`

or 

```ruby
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "<bla-bla>/cookbooks"
      chef.provisioning_path = "/tmp/vagrant-chef/chef-solo"
      chef.json = {
        :mariadb => {
          token: 'MY SECRET TOKEN'
        }
      }
      chef.add_recipe "mariadb-enterprise::install_backuper"
    end
```

Params:

`mariadb::token` - your secret token, you can get it on mariadb.com.

## uninstall_backuper

Uninstalls MariaDB backuper.

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::uninstall_backuper]`

## backup

Creates DB backup.

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::backup]`

Params:

- `mariadb::instance` - instance what backup is created for (see )
- `mariadb::backups_dir` - directory where backups are stored (/data/backups/mysql by default)
- `mariadb::root_password` - your DB's root password

## restore

Restores the last (by default) backup.

Usage:

`$ chef-solo -c solo.rb -o recipe[mariadb-enterprise::restore]`

Params:

- `mariadb::instance` - instance what backup is created for (see )
- `mariadb::restore_source_dir` - directory where particular backup is stored (by default the last is used)
- `mariadb::backups_dir` - directory where backups are stored (/data/backups/mysql by default)
- `mariadb::root_password` - your DB's root password


## Libraries

### mysql_service

The `mysql_service` resource manages the basic plumbing needed to get a
MySQL server instance running with minimal configuration.

The `:create` action handles package installation, support
directories, socket files, and other operating system level concerns.
The internal configuration file contains just enough to get the
service up and running, then loads extra configuration from a conf.d
directory. Further configurations are managed with the `mysql_config` resource.

- If the `data_dir` is empty, a database will be initialized, and a
root user will be set up with `initial_root_password`. If this
directory already contains database files, no action will be taken.

The `:start` action starts the service on the machine using the
appropriate provider for the platform. The `:start` action should be
omitted when used in recipes designed to build containers.

#### Example
```ruby
mysql_service 'default' do
  version '5.7'
  bind_address '0.0.0.0'
  port '3306'  
  data_dir '/data'
  initial_root_password 'Ch4ng3me'
  action [:create, :start]
end
```

Please note that when using `notifies` or `subscribes`, the resource
to reference is `mysql_service[name]`, not `service[mysql]`.

#### Parameters

- `charset` - specifies the default character set. Defaults to `utf8`.

- `data_dir` - determines where the actual data files are kept
on the machine. This is useful when mounting external storage. When
omitted, it will default to the platform's native location.

- `initial_root_password` - allows the user to specify the initial
  root password for mysql when initializing new databases.
  This can be set explicitly in a recipe, driven from a node
  attribute, or from data_bags. When omitted, it defaults to
  `ilikerandompasswords`. Please be sure to change it.

- `instance` - A string to identify the MySQL service. By convention,
  to allow for multiple instances of the `mysql_service`, directories
  and files on disk are named `mysql-<instance_name>`. Defaults to the
  resource name.

- `bind_address` - determines the listen IP address for the mysqld service. When
  omitted, it will be determined by MySQL. If the address is "regular" IPv4/IPv6
  address (e.g 127.0.0.1 or ::1), the server accepts TCP/IP connections only for
  that particular address. If the address is "0.0.0.0" (IPv4) or "::" (IPv6), the
  server accepts TCP/IP connections on all IPv4 or IPv6 interfaces.

- `port` - determines the listen port for the mysqld service. When
  omitted, it will default to '3306'.

- `run_group` - The name of the system group the `mysql_service`
  should run as. Defaults to 'mysql'.

- `run_user` - The name of the system user the `mysql_service` should
  run as. Defaults to 'mysql'.

- `socket` - determines where to write the socket file for the
  `mysql_service` instance. Useful when configuring clients on the
  same machine to talk over socket and skip the networking stack.
  Defaults to a calculated value based on platform and instance name.

#### Actions

- `:create` - Configures everything but the underlying operating system service.
- `:delete` - Removes everything but the package and data_dir.
- `:start` - Starts the underlying operating system service
- `:stop`-  Stops the underlying operating system service
- `:restart` - Restarts the underlying operating system service
- `:reload` - Reloads the underlying operating system service

### backup

```ruby
mysql_backup 'instance' do
  restore_source_dir "/data/backups/mysql/2010-05-06-12-47-00"
  backups_dir "/data/backups/mysql"
  root_password 'root_password'
  action :restore
end
```

There are two actions: `:create` and `:restore`, parameters lists are the same with lists for appropriate recipes.

#### Providers
Chef selects the appropriate provider based on platform and version,
but you can specify one if your platform support it.

```ruby
mysql_service[instance-1] do
  port '1234'
  data_dir '/mnt/lottadisk'
  provider Chef::Provider::MysqlService::Sysvinit
  action [:create, :start]
end
```

- `Chef::Provider::MysqlService` - Configures everything needed t run
a MySQL service except the platform service facility. This provider
should never be used directly. The `:start`, `:stop`, `:restart`, and
`:reload` actions are stubs meant to be overridden by the providers
below.

- `Chef::Provider::MysqlService::Systemd` - Starts a `mysql_service`
using SystemD. Manages the unit file and activation state

- `Chef::Provider::MysqlService::Sysvinit` - Starts a `mysql_service`
using SysVinit. Manages the init script and status.

- `Chef::Provider::MysqlService::Upstart` - Starts a `mysql_service`
using Upstart. Manages job definitions and status.


License
-----------------
Forked from https://github.com/chef-cookbooks/mysql

```text
Copyright:: 2009-2014 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
