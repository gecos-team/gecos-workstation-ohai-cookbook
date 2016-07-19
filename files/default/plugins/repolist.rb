provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

repofiles = []

begin

	Dir["/etc/apt/sources.list.d/*"].each do |repofile|
		Chef::Log.debug("ohai_gecos - repofile: #{repofile}")
		f = File.open(repofile, "r")
		sources = f.entries.select { |x| x[/(^deb\s.*?(?=#|\n|$))/] } 
		sources.map!(&:chomp)
		Chef::Log.debug("ohai_gecos - sources: #{sources}")

		repofiles <<  Mash.new(
			:filename => repofile,
			:sources	=> sources
		)
		f.close()
	end

end

ohai_gecos['repofiles'] = repofiles
