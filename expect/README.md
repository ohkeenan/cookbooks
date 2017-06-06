# Expect Cookbook
[![Chef cookbook](https://img.shields.io/cookbook/v/expect.svg)](https://supermarket.chef.io/cookbooks/expect)
[![Build Status](https://travis-ci.org/rjaros87/chef-expect.svg?branch=master)](https://travis-ci.org/rjaros87/chef-expect)

# Description

This cookbook will install [Expect package](http://expect.sourceforge.net/).
> Expect is a tool for automating interactive applications such as telnet, ftp, passwd, fsck, rlogin, tip, etc. Expect really makes this stuff trivial. Expect is also useful for testing these same applications. And by adding Tk, you can also wrap interactive applications in X11 GUIs.
> Expect can make easy all sorts of tasks that are prohibitively difficult with anything else. You will find that Expect is an absolutely invaluable tool - using it, you will be able to automate tasks that you've never even thought of before - and you'll be able to do this automation quickly and easily.

Expect requires Tcl (tool command language). This cookbook will provide Tcl package if necessary (currently only Windows platform requires it).

### Platforms

- Ubuntu
- CentOS
- RedHat
- Fedora
- Mac OS X
- Windows

### Chef

- Chef 12 or later

## Attributes

### expect::default

| Key                                             | Type    | Description                                             | Platform | Default                            |
| ------------------------------------------------| ------- | --------------------------------------------------------| -------- | -----------------------------------|
| `default['expect']['include_homebrew']`         | Boolean | Include homebrew recipe for installing brew on Mac OS   | Mac OS   | `true`                             |
| `default['expect']['cygwin']['from_system']`    | Boolean | Use the Cygwin from system                              | Windows  | `false`                            |
| `default['expect']['cygwin']['home']`           | String  | Installation path for the Cygwin                        | Windows  | `'C:\\cygwin'`                     |
| `default['expect']['cygwin']['site']`           | String  | Server where the Cygwin should search for the packages  | Windows  | `'http://cygwin.mirrors.pair.com'` |

## Recipes

### expect::default

Installs Expect package on node and if the node platform is Windows then the recipe also installs [Cygwin](https://www.cygwin.com/) component.

### Usage - expect::default

Just include `expect` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[expect]"
  ]
}
```

## Resources

This cookbook provides a script provider called `expect_script` which will execute `expect` script using Tcl according to current OS. 

| Property      | Type              | Description                                                                  | Default                            | Required |
| --------------| ----------------- | ---------------------------------------------------------------------------- | -----------------------------------| -------- |
| `cwd`         | String            | The current working directory                                                | `true`                             | false    |
| `code`        | String            | A quoted string of code to be executed                                       | `false`                            | true     |
| `environment` | Hash              | A Hash of environment variables in the form of ({"ENV_VARIABLE" => "VALUE"}) | `'C:\\cygwin'`                     | false    |
| `user`        | [String, Integer] | The user name or user ID that should be changed before running a command     | `nil`                              | false    |
| `group`       | [String, Integer] | The group name or group ID that must be changed before running a command     | `nil`                              | false    |

### Usage expect_script

```ruby
expect_script 'Example expect script with system command' do
  code <<-EOH
    spawn ftp
    set timeout 30
    expect {
      -regexp "ftp.*" {
        exp_send "bye\r"
        exp_continue
      }
      eof
    }
  EOH
end
```

```ruby
expect_script 'Example expect script with bash script' do
  cwd '/'
  environment 'PATH' => "#{ENV['PATH']}:/tmp/test"
  code <<-EOH
    spawn test.sh
    set timeout 30
    expect {
      -regexp "Would you like to delete your all files (yes/no)?.*" {
        exp_send "no\r"
        exp_continue
      }
      eof
    }
  EOH
  user 'root'
  group 'root'
end
```

## Contributing

* [Contribution Guidelines](https://github.com/rjaros87/chef-expect/blob/master/CONTRIBUTING.md)

## License and Authors

Authors: Radoslaw Jaros
