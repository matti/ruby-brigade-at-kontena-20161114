require 'kommando'

Kommando.run "ping -c 4 google.com", {
  output: true
}

puts "\n\nscale to 64 instances!"
sleep 2

Kommando.run_async "kontena service scale rubybrigade-whoami-web 64"
monitor = Kommando.run_async "kontena service monitor rubybrigade-whoami-web", {
  output: true
}

monitor.out.on "64/64 instances" do
  monitor.in.write "\x03"
end

monitor.wait

puts "\n\nNext up: Links"
sleep 2


links = Kommando.run_async "links http://rubybrigade-whoami.appgyver.com", {
  output: true
}

def links.open_menu
  self.in << "\e"
  sleep 0.25
  self.in << "\r"
  sleep 0.25
end

def links.go_down_n_and_hit_enter(n)
  n.times do
    self.in << "\e[B"
    sleep 0.25
  end
  self.hit_enter
end

def links.hit_enter
  self.in << "\r"
end

sleep 2

3.times do
  links.open_menu
  links.go_down_n_and_hit_enter 4

  sleep 1.25
end

links.open_menu
links.go_down_n_and_hit_enter 14
links.hit_enter

links.wait



puts "\n\nNext up: nano"
sleep 2

nano = Kommando.run_async "nano ruby-rules.txt", {
  output: true
}

"RUBY RULES".split("").each do |c|
  nano.in << c
  sleep 0.25
end

nano.in << "\r"
nano.in << "\x1B\x1Bx"

nano.out.on "Save modified buffer" do
  sleep 1
  nano.in << "y"
  nano.out.on "File Name to Write" do
    sleep 1
    nano.in << "\r"
  end
end

nano.wait

puts "\n\nta-da!"
