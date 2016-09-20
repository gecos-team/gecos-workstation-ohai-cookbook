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
      lpoptions = Mixlib::ShellOut.new("lpoptions -p #{printer}")
      lpoptions.run_command
      lpq = Mixlib::ShellOut.new("lpq -P #{printer}")
      lpq.run_command
      lpstat = Mixlib::ShellOut.new("lpstat -p #{printer}")
      lpstat.run_command

      /printer-make-and-model='(?<printerBrand>.*)'/  =~ lpoptions.stdout
      /printer-make-and-model='(?<printerDriver>.*)'/ =~ lpoptions.stdout
      /device-uri=(?<printerConn>\S+)/                =~ lpoptions.stdout
      printerStatus = lpstat.stdout
      printerQueue  = lpq.stdout

      thisprinter Mash.new
      thisprinter[:name]            = printer
      thisprinter[:brand_and_model] = printerBrand
      thisprinter[:driver]          = printerDriver
      thisprinter[:connection]      = printerConn
      thisprinter[:status]          = printerStatus
      thisprinter[:queue]           = printerQueue
      printers << thisprinter
    end
  end
  rescue Exception => e
    puts "Command output failed\n" + e.message
end

ohai_gecos['printers'] = printers
