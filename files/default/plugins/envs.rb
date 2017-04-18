provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end
begin
  envvars = ''
  fp = File.open('/etc/environment','r')
  envvars = fp.read
  fp.close

  #envs = Hash[envvars.each_line.map { |l| l.gsub!(/"/, '').chomp.split('=',2)}]
  envs = Hash[envvars.each_line.map { |l| l.gsub(/"?(.*?)"?/m, '\1').chomp.split('=',2)}]
  
rescue Exception => e
  puts e.message
end

ohai_gecos['envs'] = envs
