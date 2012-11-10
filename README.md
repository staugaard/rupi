# Rupi

A ruby interface for the raspberrypi's GPIO.

## Installation

```bash
gem install rupi
```

## Usage

After installing the gem you can generate an application like this:

```
~% rupi new blink
      create  blink/Gemfile
      create  blink/Capfile
      create  blink/app.rb
      create  blink/.bundle/config
~% cd blink
~/blink% bundle
Fetching gem metadata from https://rubygems.org/.......
Using highline (1.6.15)
Using net-ssh (2.6.1)
Using net-scp (1.0.4)
Using net-sftp (2.0.5)
Using net-ssh-gateway (1.1.0)
Using capistrano (2.13.5)
Using daemons (1.1.9)
Using thor (0.16.0)
Using rupi (0.4.9)
Using bundler (1.2.1)
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
~/blink%
```

You now have an application in the blink directory.

### The Generated Application

The generated application will "blink" pin0. To try it out connect an LED to GND/0v and to pin0/GPIO0/17.
Remember to use an appropriate resistor for your LED.

What's up with the names of the pins you ask? Read on...

### Pin Names

The rupi library uses the wiringpi gem for talking to the pins of the raspberrypi. We use the same pin numbering as the wiringpi gem.
The creator of the wiringpi gem has a great diagram you can use to locate the right pins here: https://projects.drogon.net/raspberry-pi/wiringpi/pins

### Running the Code

You need to update the `Capfile` in your application directory to make sure that the hostname of your raspberrypi is right.

When running the code for the first time you need to prepare your raspberrypi. This is easy but takes a while.
Just run `bundle exec cap deploy:setup`. This will install all the software that you need to run your application.
Once the installation is complete it will also deploy and run your application.

When you later update your application and want to update the code on the raspberrypi, your simply run `bundle exec cap deploy`

### API

You can access 15 pins through the constants PIN0 - PIN14. Before you can use a pin, you have to specify if you want it to be used for
input or output.

```ruby
PIN0.input!
PIN1.output!
```

after that you can access the pins:

```ruby
value_of_pin_0 = PIN0.value
PIN1.value = 1
```

You can also flip the value of an output pin with the `toggle` method:

```ruby
PIN1.toggle
```

You can read the value of input pins whenever you want, but you can also set up hooks for when the values change:

```ruby
PIN0.change do |value|
  puts "pin 0 changed to #{value}"
end

PIN0.up do
  puts "pin 0 changed up to 1"
end

PIN0.down do
  puts "pin 0 changed down to 0"
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
