provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

begin
  entries = []
  printers = []

  entries = Mixlib::ShellOut.new("lpstat -a | awk {'print $1'}")
  entries.run_command

  if entries.exitstatus == 0
    entries.stdout.split(/\r?\n/).each do |printer|
      lpo = Mixlib::ShellOut.new("lpoptions -p #{printer}")
      lpq = Mixlib::ShellOut.new("lpq -P #{printer}")
      lps = Mixlib::ShellOut.new("lpstat -p #{printer}")
      lpo.run_command
      lpq.run_command
      lps.run_command
      printerStatus = lps.stdout
      printerQueue  = lpq.stdout
      thisprinter Mash.new
      thisprinter[:status] = printerStatus
      thisprinter[:queue]  = printerQueue
      p = lpo.stdout.scan(/(?:\S+='.+?')|(?:\S+=\S+)/)
      p.each { |x| thisprinter[x.split(/=(.*)/)[0]] = x.split(/=(.*)/)[1]}
      printers << thisprinter
    end
  end
  rescue Exception => e
    puts "Command output failed\n" + e.message
end

ohai_gecos['printers'] = printers
