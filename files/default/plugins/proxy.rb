provides 'ohai_gecos'

if ohai_gecos.nil?
  ohai_gecos Mash.new
end

require 'uri'

begin
  
  fp = File.open('/etc/environment', 'r')
  envvars = fp.read
  fp.close
  
  http_proxy  = envvars.scan(/http_proxy=(.*)/i).flatten.pop  || ENV['HTTP_PROXY']  || ENV['http_proxy']  || '' 
  https_proxy = envvars.scan(/https_proxy=(.*)/i).flatten.pop || ENV['HTTPS_PROXY'] || ENV['https_proxy'] || ''
  
  http_proxy_host  = URI.parse(http_proxy).host  
  http_proxy_port  = URI.parse(http_proxy).port  || 80
  https_proxy_host = URI.parse(https_proxy).host 
  https_proxy_port = URI.parse(https_proxy).port || 443

  proxy = Mash.new(
      :http_proxy_host  => http_proxy_host,
      :http_proxy_port  => http_proxy_port,
      :https_proxy_host => https_proxy_host,
      :https_proxy_port => https_proxy_port
  )

rescue Exception => e
  puts "Proxy not found\n" + e.message
end

ohai_gecos['proxy'] = proxy
