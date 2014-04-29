provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

ohai_gecos['pclabel'] from("cat /etc/pclabel")
