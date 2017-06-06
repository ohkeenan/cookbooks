#
# Cookbook Name:: expect
# Resource:: script
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

property :cwd, kind_of: String
property :code, kind_of: String, required: true
property :environment, kind_of: Hash
property :user, kind_of: [String, Integer]
property :group, kind_of: [String, Integer]

default_action :run

action :run do
  if node['platform_family'] == 'windows'
    new_resource.environment.each do |key, val|
      ENV[key] = val
    end
  end

  script 'Execute Expect script' do
    interpreter 'expect'
    cwd new_resource.cwd
    environment new_resource.environment
    user new_resource.user
    group new_resource.group
    code new_resource.code
  end
end
