provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

def getTagValue(ptr,tag)
	# this function needs two parameters:
	#  - ptr: name of the printer to be processed
	#  - tag: tag to be extracted
	# It returns two possible values:
	#  - the value of tag
	#  - false in case tag doesn't exist in ptr declaration

	printerFound = false

	begin
		fp = File.open('/etc/cups/printers.conf', 'r')
		f_printers = fp.read
		fp.close
	rescue
		puts "file doesn't exist"
		return false
	end

	if not f_printers.empty?
		f_printers.each_line do |line|
			if line.match(/^<Printer #{Regexp.escape ptr}>$/)
				printerFound = true
				next
			end
			if line.match(/^#{Regexp.escape tag} (.*)$/) and printerFound
				return $1
			end
			if line.match(/^<\/Printer>$/) and printerFound
				return false
			end
		end
	end
end

begin
  entries = []
  printers = []

  entries = Mixlib::ShellOut.new("lpstat -a | egrep '^\\S' | awk '{print $1}'")
  entries.run_command

  if entries.exitstatus == 0
    entries.stdout.split(/\r?\n/).each do |printer|
      lpo = Mixlib::ShellOut.new("lpoptions -p #{printer}")
      lpo.run_command
        if lpo.exitstatus == 0
            lpq = Mixlib::ShellOut.new("lpq -P #{printer}")
            lps = Mixlib::ShellOut.new("lpstat -p #{printer}")
            lpq.run_command
            lps.run_command
            printerStatus = lps.stdout
            printerQueue  = lpq.stdout
            thisprinter Mash.new
            thisprinter[:status] = printerStatus
            thisprinter[:queue]  = printerQueue
            puts printer.gsub("+","\+")
            puts printer.gsub("+","\\+")
            thisprinter[:oppolicy] = getTagValue(printer, 'OpPolicy')
            p = lpo.stdout.scan(/(?:\S+='.+?')|(?:\S+=\S+)/)
            p.each { |x| thisprinter[x.split(/=(.*)/)[0]] = x.split(/=(.*)/)[1]}
            printers << thisprinter
        else
            next
        end
    end
  end
  rescue Exception => e
    puts "Command output failed\n" + e.message
end

ohai_gecos['printers'] = printers
