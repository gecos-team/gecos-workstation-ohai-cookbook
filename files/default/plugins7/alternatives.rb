
Ohai.plugin(:Alternatives) do
    provides 'ohai_gecos'

    collect_data do
        if ohai_gecos.nil?
          ohai_gecos Mash.new
        end
        begin
            alternatives_data = Hash.new
            # Check all the alternatives
            alternatives_elems = %x[update-alternatives --get-selections]
            alternatives_elems.each_line do |line|
                alternative_name = line.scan( /[ ]*([^ ]+)/).first.first
                
                # Get information about one alternative
                if $ohai_new_config_syntax
                  data = shell_out('update-alternatives', '--display', alternative_name).stdout
                else
                  stdin, stdout, stderr, wait_thr = Open3.popen3('update-alternatives', '--display', alternative_name)
                  data = stdout.gets(nil)
                  stdout.close
                  stderr.gets(nil)
                  stderr.close
                end
                Chef::Log.debug("alternatives.rb: data = #{data}")
                
                # parse the information
                current_opt = 'UNKNOWN'
                available_opt = Array.new
                nline = 0
                data.each_line do |altline|
                    nline = nline + 1
                    if ( nline == 2 )
                        current_opt = altline.scan( /(\/[^$]+)$/i).first.first.strip
                        
                    elsif ( altline =~ /prioridad/ or altline =~ /priority/ )
                        avail_opt = Hash.new
                        avail_opt['path'] = altline.scan( /^([^ ]+) \- /).first.first
                        avail_opt['priority'] = altline.scan( /([0-9]+)$/).first.first
                        
                        available_opt.push(avail_opt)
                        
                    end
                end
                
                
                
                alternatives_data[alternative_name] = Hash.new
                alternatives_data[alternative_name]['selected'] = current_opt
                alternatives_data[alternative_name]['available'] = available_opt
                
                puts "+"+alternative_name
            end 

        rescue Exception => e
          puts e.message
        end

        ohai_gecos['alternatives'] = alternatives_data

    end
end
