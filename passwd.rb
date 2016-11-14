require 'kommando'

passwd = Kommando.new "passwd", {
  output: true,
  timeout: 3
}

passwd.out.on /Changing password for \w+\./ do
  passwd.out.on "Old Password" do
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
