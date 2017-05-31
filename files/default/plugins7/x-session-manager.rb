
Ohai.plugin(:XSessionManager) do
    provides 'ohai_gecos'
    
    collect_data do

        if ohai_gecos.nil?
          ohai_gecos Mash.new
        end


        begin
          desktop_session from("readlink /etc/alternatives/x-session-manager  | xargs basename")
        rescue Exception => e
          puts e.message
        end

        ohai_gecos['desktop_session'] = desktop_session

    end
end