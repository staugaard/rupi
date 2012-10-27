require 'tempfile'

module Rupi
  class Camera
    CONFIGURATION = {
      :width      => 640,
      :height     => 480,
      :gain       => 80,
      :brightness => 80,
      :contrast   => 80,
      :saturation => 80
    }

    def self.configure(options = {})
      CONFIGURATION.merge!(options)
    end

    def self.capture(options = {})
      cfg = CONFIGURATION.merge(options)

      path = options[:path]

      if path.nil?
        file = Tempfile.new('snap')
        path = file.path
      end

      command = "uvccapture -S#{cfg[:saturation]} -B#{cfg[:brightness]} -C#{cfg[:contrast]} -G#{cfg[:gain]} -x#{cfg[:width]} -y#{cfg[:height]}"

      system("#{command} -o#{path}")

      file || File.new(path)
    end
  end
end