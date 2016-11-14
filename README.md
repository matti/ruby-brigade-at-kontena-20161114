



# Ruby Brigade Helsinki at Kontena - 14.11.2016

```

  "3+1 wonderful ruby related things"

  github.com/matti
  @mattipaksula
  matti.paksula@appgyver.com

```


## +1 wonderful thing: ryby


```shell
$ gem install ryby-cli
```







```shell
$ ryby init ruby-brigade-at-kontena-20161114 2.3.1
```










```
$ tree -a ruby-brigade-at-kontena-20161114
ruby-brigade-at-kontena-20161114
├── .ruby-gemset
├── .ruby-version
└── Gemfile
```






```shell
$ cd ruby-brigade-at-kontena-20161114
ruby-2.3.1 - #gemset created /Users/mpa/.rvm/gems/ruby-2.3.1@ruby-brigade-at-kontena-20161114
ruby-2.3.1 - #generating ruby-brigade-at-kontena-20161114 wrappers - please wait
```

```shell
$ cat Gemfile
source 'https://rubygems.org'
```


(github.com/matti/ruby-brigade-at-kontena-20161114)






## 1st wonderful thing, kontena, your own heroku

Written naturally in ruby <3

```shell
$ echo "gem 'kontena-cli'" >> Gemfile
$ bundle
```


```shell
$ kontena help
Usage:
    kontena [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    cloud                         Kontena Cloud specific commands
    logout                        Logout from Kontena
    grid                          Grid specific commands
    app                           App specific commands
    service                       Service specific commands
    vault                         Vault specific commands
    certificate                   LE Certificate specific commands
    node                          Node specific commands
    master                        Master specific commands
    vpn                           VPN specific commands
    registry                      Registry specific commands
    container                     Container specific commands
    etcd                          Etcd specific commands
    external-registry             External registry specific commands
    whoami                        Shows current logged in user
    plugin                        Plugin related commands
    version                       Show version
```




```shell
$ kontena version
cli: 0.16.2
master: 0.15.3
```




## Q: How do you install older version of a cli gem?







a)

  `gem install kontena-cli -v 0.15.3`




b)

  `gem 'kontena-cli', '0.15.3'`





c)

  `docker`





## 2nd wonderful thing: docker wrappers

```shell
$ docker run -it --rm \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/home/kontena \
    kontena/cli:${KONTENA_VERSION} version
```




--> shell wrapper [contena](https://github.com/matti/contena)



`$ KONTENA_VERSION=0.15.3 contena version`






```shell
$ KONTENA_VERSION=0.15.3 contena version
Unable to find image 'kontena/cli:0.15.3' locally
0.15.3: Pulling from kontena/cli
117f30b7ae3d: Pull complete
ccbddebfe5ff: Pull complete
b9f0c48384b7: Downloading [==================>         ] 6.88MB
```

......downloading...


```shell
b9f0c48384b7: Pull complete
Digest: sha256:d689363500adb967b9150c6670ca81ff86f60b660503450cf31
Status: Downloaded newer image for kontena/cli:0.15.4
cli: 0.15.4
```




```shell
$ KONTENA_VERSION=0.15.3 contena version
cli: 0.15.3
$ KONTENA_VERSION=0.15.4 contena version
cli: 0.15.4
```


Same works for other binaries like ffmpeg, youtube-dl ...
(instead of homebrew/macports)









...and even chrome / firefox (on mac XQuartz as X server)









## 3rd wonderful thing: Kommando

```shell
$ echo "gem 'kommando'" >> Gemfile
$ bundle
```

for automating shell stuff like ssh, etc.






## Q: expect anyone?

```python
#! /bin/env expect

# Characters per minute
set speed 20

proc main {} {
    variable speed
    set control 10
    expect_user -re . {
        send_user -- $expect_out(buffer)
        if {$expect_out(buffer) eq "\x1b"} {
            set control 6
        } else {
            incr control -1
            incr proont
        }
        if {$control < 1 && ! [string is space $expect_out(buffer)]} {
            after [expr {60 / $speed}]
        }
        exp_continue
    } eof {}
}
main
```


## That's not ruby :(







This is ruby (ping.rb)[ping.rb]

```ruby
require 'kommando'

ping = Kommando.new "ping -c 1 google.com"

ping.out.on /64 bytes from/ do
  puts "got pong!"
end

ping.run
```




Nested matching: (passwd.rb)[passwd.rb]

```ruby
require 'kommando'

passwd = Kommando.new "passwd", {
  output: true
}



passwd.out.on /Changing password for \w+\./ do
  passwd.out.on "Old Password:" do
    passwd.in.writeln "p4ssw0rd"

    passwd.out.on "New Password:" do
      passwd.in.writeln "betterp4ssw0rd"

      passwd.out.on "Retype New Password:" do
        passwd.in.writeln "betterp4ssw0rd"
      end
    end
  end
end

passwd.run
```

## even MORE features!

 - in-line shell scripts:
  Kommando.run "$ ls -l | grep lol"
 - Timeout support
 - stdout / stderr to a file
 - kill process
 - callbacks on events like "start", "exited"
 - exit codes etc





## Real life Kommando with Kontena

Speaker notes:

```shell
kontena node ls
kontena grid show gcp-1

open http://rubybrigade-whoami.appgyver.com




kontena service scale rubybrigade-whoami-web 8 &>/dev/null &
kontena service monitor rubybrigade-whoami-web




links http://rubybrigade-whoami.appgyver.com



kontena service scale rubybrigade-whoami-web 3





ruby megademo.rb
```

See: (megademo.rb)[megademo.rb]

```ruby
require 'kommando'

Kommando.run "ping -c 4 google.com", {
  output: true
}

puts "\n\n scale to 64 instances!"
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
```


















```shell
___________.__                   __           ._.
\__    ___/|  |__ _____    ____ |  | __  _____| |
  |    |   |  |  \\__  \  /    \|  |/ / /  ___/ |
  |    |   |   Y  \/ __ \|   |  \    <  \___ \ \|
  |____|   |___|  (____  /___|  /__|_ \/____  >__
                \/     \/     \/     \/     \/ \/
```                
