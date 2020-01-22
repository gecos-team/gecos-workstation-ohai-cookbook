
Ohai.plugin(:AptCheck) do
    provides 'ohai_gecos'
    
    collect_data do

        if ohai_gecos.nil?
          ohai_gecos Mash.new
        end
        
        begin
          alternatives_elems = %x[apt-get check]
        rescue Exception => e
          puts e.message
        end

        ohai_gecos['apt-check'] = aptcheck

    end
end