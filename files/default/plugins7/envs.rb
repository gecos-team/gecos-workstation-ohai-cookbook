Ohai.plugin(:Envs) do

    provides 'ohai_gecos'

    collect_data do

        if ohai_gecos.nil?
          ohai_gecos Mash.new
        end
        begin
          envvars = ''
          fp = File.open('/etc/environment','r')
          envvars = fp.read
          envvars.gsub! /^$\n/, ''
          fp.close

          envs = Hash[envvars.each_line.map { |l| l.gsub(/(?:")*?([^"]+)(?:")*?/, '\1').chomp.split('=',2)}]
  
        rescue Exception => e
          puts e.message
        end

        ohai_gecos['envs'] = envs
    end
end
