require 'wiringpi'

module Rupi
  class Pin

    class GPIO < WiringPi::GPIO
      def pullUpDnControl(pin, pud)
        Wiringpi.pullUpDnControl(pin, pud)
      end
    end

    attr_reader :number, :up_handlers, :down_handlers

    def initialize(number)
      @number = number

      @up_handlers   = []
      @down_handlers = []
    end

    def gpio
      self.class.gpio
    end

    def self.gpio
      @gpio ||= GPIO.new
    end

    def input!(pud = PUD_DOWN)
      gpio.mode(number, INPUT)
      gpio.pullUpDnControl(number, pud) if pud
    end

    def output!
      gpio.mode(number, OUTPUT)
    end

    def value
      gpio.read(number)
    end

    def value=(value)
      value = 1 if value == true
      value = 0 if value == false

      gpio.write(number, value)
    end

    def toggle
      self.value = value != 1
    end

    def up(&block)
      @up_handlers << block
      self.class.watch(self)
    end

    def down(&block)
      @down_handlers << block
      self.class.watch(self)
    end

    def change(&block)
      @up_handlers   << block
      @down_handlers << block
      self.class.watch(self)
    end

    def self.watch(pin)
      @watched_pins ||= {}
      @watched_pins[pin] ||= nil
      start_watching
    end

    def self.unwatch(pin)
      return unless @watched_pins
      if pin == :all
        @watched_pins.clear
      else
        @watched_pins.delete(pin)
      end
    end

    def self.start_watching
      @watching = true

      @watch_thread ||= Thread.new do

        while @watching && !@watched_pins.empty? do
          @watched_pins.each do |pin, previous_value|
            value = pin.value
            if previous_value && previous_value != value
              handlers = value == 1 ? pin.up_handlers : pin.down_handlers
              handlers.each do |handler|
                handler.call(value)
              end
            end
            @watched_pins[pin] = value
          end
          sleep(0.1)

        end
      end
    end

    def self.stop_watching
      @watching = false
      join_watch_thread
    end

    def self.watching?
      @watching
    end

    def self.join_watch_thread
      return unless @watch_thread
      @watch_thread.join
    end

  end
end
