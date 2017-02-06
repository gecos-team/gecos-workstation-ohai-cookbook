provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end
begin
  grub_options = Hash.new
  submenu_stack = Array.new

  tags_stack = Array.new
  last_tag = 'ROOT'
  tags_stack.push(last_tag)
  menuentry = 'UNKNOWN'
  
  lineno = 0
  File.open('/boot/grub/grub.cfg','r') do |grubconf_file|
    grubconf_file.each_line do |line|
        lineno = lineno + 1
        if ( line =~ /menuentry ([^{]+){/ )
            menuentry = 'UNKNOWN'
            if ( line =~ /menuentry[ ]+'([^']+)'/ )
                menuentry = line.scan( /'([^']+)'/).first.first
            end
            if ( line =~ /menuentry[ ]+"([^"]+)"/ )
                menuentry = line.scan( /"([^"]+)"/).first.first
            end
            
            #puts lineno.to_s+" MENUENTRY:"+menuentry
            grub_options[menuentry] = ''
            tags_stack.push('menuentry')
            last_tag = 'menuentry'
            
        elsif ( line =~ /submenu ([^{]+){/ )
            submenu = 'UNKNOWN'
            if ( line =~ /submenu[ ]+'([^']+)'/ )
                submenu = line.scan( /'([^']+)'/).first.first
            end
            if ( line =~ /submenu[ ]+"([^"]+)"/ )
                submenu = line.scan( /"([^"]+)"/).first.first
            end
                
            #puts lineno.to_s+" SUBMENU:"+submenu
            tags_stack.push('submenu')
            last_tag = 'submenu'
            submenu_elements = Hash.new
            submenu_stack.push(grub_options)
            grub_options[submenu] = submenu_elements
            grub_options = submenu_elements
            
        elsif ( line =~ /function ([^{]+){/ )
            funcname = 'UNKNOWN'
            if ( line =~ /function[ ]+([^ {]+)/ )
                funcname = line.scan( /function[ ]+([^ {]+)/).first.first
            end
        
            #puts lineno.to_s+" FUNCTION:"+funcname+" "+lineno.to_s
            tags_stack.push('function')
            last_tag = 'function'

            
        elsif ( line =~ /([^{]+){/ and not line =~ /\${/ )
            elmtag = line.scan( /[ ]*([^ {]+)/).first.first
            tags_stack.push(elmtag)
            last_tag = elmtag            
            #puts "UNKNOWN TAG:"+elmtag+" "+lineno.to_s
        
        elsif ( line =~ /}/ and not line =~ /\${/ )
            last_tag = tags_stack.pop()
            #puts lineno.to_s+' END '+last_tag
            if (last_tag == 'submenu')
                grub_options = submenu_stack.pop()
            elsif (last_tag == 'ROOT')
                tags_stack.push(last_tag)
            end
            
        elsif (last_tag == 'menuentry' and not grub_options.nil? and not line.nil?)
            grub_options[menuentry] += line+"\n"
            
        end
        
    end    
    
    #puts JSON.dump grub_options
  end

rescue Exception => e
  puts e.message
end

ohai_gecos['grub_options'] = grub_options
