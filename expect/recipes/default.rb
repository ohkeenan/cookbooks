#
# Cookbook Name:: expect
# Recipe:: default
#
# Copyright 2016, Radoslaw Jaros
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'debian', 'rhel'
  package 'expect'
when 'mac_os_x'
  include_recipe 'homebrew' if node['expect']['include_homebrew']
  homebrew_tap 'homebrew/dupes'
  homebrew_package 'expect'
when 'windows'
  if node['expect']['cygwin']['from_system']
    Chef::Log.info('Skipping the Cygwin installation because the attribute [\'expect\'][\'cygwin\'][\'from_system\'] is set to true')
  else
    node.default['cygwin']['home'] = node['expect']['cygwin']['home']
    node.default['cygwin']['site'] = node['expect']['cygwin']['site']

    include_recipe 'cygwin::default'

    cygwin_package 'expect' do
      action :install
    end
  end
else
  Chef::Log.error "Platform '#{node['platform_family']}' not supported!"
end
