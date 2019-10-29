name             "ohai-gecos"
maintainer       "Opscode, Inc"
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Distributes a directory of custom ohai plugins"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.13.0"

depends "chef-client"

recipe "ohai::default", "Distributes a directory of custom ohai plugins"

attribute "ohai/plugin_path",
  :display_name => "Ohai Plugin Path",
  :description => "Distribute plugins to this path.",
  :type => "string",
  :required => "optional",
  :default => "/etc/chef/ohai_plugins"
