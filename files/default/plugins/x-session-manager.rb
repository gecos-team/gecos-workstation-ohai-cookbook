
provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end


begin
  if $ohai_new_config_syntax
    desktop_session = shell_out("readlink /etc/alternatives/x-session-manager  | xargs basename")
  else
    desktop_session = Mixlib::ShellOut.new("readlink /etc/alternatives/x-session-manager  | xargs basename")
    desktop_session.run_command
  end
  Chef::Log.debug("x-session-manager.rb: desktop_session = #{desktop_session.stdout}")

rescue Exception => e
  puts e.message
end

ohai_gecos['desktop_session'] = desktop_session.stdout
