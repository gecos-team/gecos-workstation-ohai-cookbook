provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

repositories = []

begin

  # Regex .deb, deb-src
  pattern = /(^(deb|deb-src)\s.*?(?=#|\n|$))/

	Dir["/etc/apt/sources.list","/etc/apt/sources.list.d/*"].each do |repofile|
		Chef::Log.debug("ohai_gecos - repofile: #{repofile}")
		f = File.open(repofile, "r")
		sources = f.entries.select { |x| x[pattern] } 
		sources.map!(&:chomp)
    sources.map! { |x| x.split.join(" ") }

		Chef::Log.debug("ohai_gecos - sources: #{sources}")

		repositories <<  Mash.new(
			:filename => repofile,
			:sources	=> sources
		)
		f.close()
	end

end

ohai_gecos['repositories'] = repositories
