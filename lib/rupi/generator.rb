require 'thor'
require 'pathname'

module Rupi
  class Generator < Thor
    include Thor::Actions

    attr_reader :name

    desc 'new NAME', 'Creates a new rupi application'
    def new(name)
      @name = name
      copy_file 'Gemfile',       "#{name}/Gemfile"
      template  'Capfile.erb',   "#{name}/Capfile"
      copy_file 'app.rb',        "#{name}/app.rb"
      copy_file 'bundle_config', "#{name}/.bundle/config"
    end

    def self.source_root
      Pathname.new(__FILE__) + '../../../templates'
    end
  end
end
