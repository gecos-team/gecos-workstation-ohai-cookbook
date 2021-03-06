
Ohai.plugin(:AptCheck) do
    provides 'ohai_gecos'
    
    collect_data do

        if ohai_gecos.nil?
          ohai_gecos Mash.new
        end
        
        aptcheck = Mash.new
        begin
          aptcheck = %x[apt-get check]
          if $?.success?
            aptcheck = "OK"  
          end
        rescue Exception => e
          puts e.message
        end

        ohai_gecos['apt-check'] = aptcheck

    end
end