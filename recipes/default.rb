#
# Cookbook Name:: ohai
# Recipe:: default
#
# Copyright 2011, Opscode, Inc
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


Chef::Log.info('Chef client version check')

current_client_version = node['chef_packages']['chef']['version']
power = 1_000_000
cclient_version = current_client_version.split('.')
integer_current_client_version = cclient_version.inject(0) do |sum, val|
  power /= 100
  sum + val.to_i * power
end

# Force chef-client update if version is older than 12.20.
if integer_current_client_version < 122_000
  Chef::Log.info('Chef client upgrade required')
  $update_cmd = `apt-get update`
  $upgrade_agent =  `apt-get install chef`
# Relaunch itself right now
  exec( '/usr/bin/chef-client' )
end



$ohai_new_config_syntax=Gem::Requirement.new('>= 8.6.0').satisfied_by?(Gem::Version.new(Ohai::VERSION))
Chef::Log.debug("ohai_new_config_syntax = #{$ohai_new_config_syntax}")

if $ohai_new_config_syntax
  if !Ohai.config[:plugin_path].include?(node['ohai']['plugin_path'])
    Ohai.config[:plugin_path] << node['ohai']['plugin_path']
  end
else
  if !Ohai::Config[:plugin_path].include?(node['ohai']['plugin_path'])
    Ohai::Config[:plugin_path] << node['ohai']['plugin_path']
  end
end
Chef::Log.info("ohai plugins will be at: #{node['ohai']['plugin_path']} ohai version is #{Ohai::VERSION}")

version_major = Ohai::VERSION.split[0].to_i
Chef::Log.info("ohai version major is #{version_major}")
source_path = 'plugins'
if version_major > 6
	source_path = 'plugins7'
end

rd = remote_directory node['ohai']['plugin_path'] do
  source source_path
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :nothing
end

rd.run_action(:create)

# only reload ohai if new plugins were dropped off OR
# node['ohai']['plugin_path'] does not exists in client.rb
regex = $ohai_new_config_syntax ? /ohai.plugin_path\s*<<\s*["']#{node['ohai']['plugin_path']}["']/ : /Ohai::Config\[:plugin_path\]\s*<<\s*["']#{node['ohai']['plugin_path']}["']/
Chef::Log.debug("regex = #{regex}")

if rd.updated? || !(::IO.read(Chef::Config[:config_file]) =~ regex)

  ohai 'custom_plugins' do
    action :nothing
  end.run_action(:reload)

end
