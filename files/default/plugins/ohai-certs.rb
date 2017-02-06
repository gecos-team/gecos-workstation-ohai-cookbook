provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

require 'etc'
calist = Mash.new
Dir["/home/*/.mozilla/firefox/*default"].each do |profile_dir|
  begin
     calist[profile_dir] = {}    
    `certutil -L -d '#{profile_dir}' `.each_line("\n"){|lin| 
      parts = lin.rstrip.split('  ')
      if parts[0] and parts[-1] and parts[0] !~/^Certificate Nickname/ and !parts[0].empty? 
        calist[profile_dir]["#{parts[0]}"] = parts[-1].strip
      end
      }
  rescue Exception => e
    puts 'Error reading ' + profile_dir+ e.inspect
  end
end

ohai_gecos['ffox_certs'] = calist

