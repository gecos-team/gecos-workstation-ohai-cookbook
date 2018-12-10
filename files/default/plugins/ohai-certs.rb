provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

ca_certs = `awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt | grep -oP '^subject=\\K.*' | sed 's/, \\([A-Z][A-Z]\\?\\)\\( \\)\\?=/\\/\\1=/g' |  awk -F '/' '{print $NF}' | grep -E '(CN|OU)( )?=' | awk -F '=' '{print $NF}' | sed 's/^ //' | sort`
ca_certs = ca_certs.gsub!(/\\x([A-F0-9][A-F0-9])/n) { $1.hex.chr }
ca_certs = ca_certs.force_encoding('utf-8')
ohai_gecos['ca-certificates'] = ca_certs.split("\n")
