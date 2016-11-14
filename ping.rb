require 'kommando'

ping = Kommando.new "ping -c 1 google.com"

ping.out.on /64 bytes from/ do
  puts "got pong!"
end

ping.run
