
Ohai.plugin(:Users) do
    provides 'ohai_gecos'
    
    collect_data do

        if ohai_gecos.nil?
          ohai_gecos Mash.new
        end

        require 'etc'
        require 'rest_client'
        require 'json'
        users = []
        # LikeWise create the user homes at /home/local/DOMAIN/
        homedirs = Dir["/home/*"] + Dir["/home/local/*/*"]
        grp_sudo = Etc.getgrnam('sudo')
        # Users in group nogecos will not be collected nor created in the Control Center tree
        begin
          grp_nogecos = Etc.getgrnam('nogecos')
          excluded_users = grp_nogecos.mem
        rescue
          excluded_users = []
        end
        homedirs.each do |homedir|
          temp=homedir.split('/')
          user=temp[temp.size()-1]
          begin
            entry=Etc.getpwnam(user)
            if not excluded_users.include?(entry.name)
              users << Mash.new(
                :username => entry.name,
                :home     => entry.dir,
                :gid      => entry.gid,
                :uid      => entry.uid,
                :sudo     => grp_sudo.mem.include?(entry.name)
              )
            end
          rescue Exception => e
            puts 'User ' + user + ' doesn\'t exists'
          end
        end

        ohai_gecos['users'] = users

    end
end
