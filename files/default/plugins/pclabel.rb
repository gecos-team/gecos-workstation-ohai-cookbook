provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

pclabel = ''
File.open('/etc/pclabel','r') do |pclabelfile|
  pclabel = pclabelfile.gets.chomp!
end


ohai_gecos['pclabel'] = pclabel