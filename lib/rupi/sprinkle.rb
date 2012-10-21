require 'rupi/version'

Sprinkle::Installers::Apt.class_eval do
  alias_method :install_commands_original, :install_commands

  def install_commands
    "sudo #{install_commands_original}"
  end
end

RVM_PATH = '/usr/local/rvm'
RVM_EXECUTABLE = "#{RVM_PATH}/bin/rvm"

package :rvm do
  description 'Ruby Version Manager'

  noop do
    pre :install, "sudo curl -L get.rvm.io | sudo bash -s stable --path #{RVM_PATH}"
  end

  verify do
    has_file RVM_EXECUTABLE
  end
end

package :ruby_dependencies do
  apt 'build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config'
end

package :ruby do
  description Rupi::RUBY_VERSION
  version Rupi::RUBY_VERSION
  requires :rvm
  requires :ruby_dependencies

  noop do
    pre :install, "sudo #{RVM_EXECUTABLE} mount -r https://s3.amazonaws.com/rvm-pi/debian/wheezy_sid/armv6l/#{Rupi::RUBY_VERSION}.tar.bz2 --verify-downloads 1"
    # pre :install, "sudo #{RVM_EXECUTABLE} install #{Rupi::RUBY_VERSION} --trace"
    post :install, "#{RVM_EXECUTABLE} use #{Rupi::RUBY_VERSION} --default"
  end

  verify do
    has_executable "#{RVM_PATH}/rubies/#{Rupi::RUBY_VERSION}/bin/ruby"
  end
end

package :rupi do
  description 'Rupi'
  requires :rvm
  requires :ruby

  apt 'uvccapture'

  noop do
    pre :install, "#{RVM_PATH}/bin/gem-#{Rupi::RUBY_VERSION} install rupi --no-rdoc --no-ri"
  end

  verify do
    has_executable "#{RVM_PATH}/gems/#{Rupi::RUBY_VERSION}/bin/rupi"
    has_executable 'uvccapture'
  end
end

policy :rupi, :roles => :raspberrypi do
  requires :rupi
end

deployment do
  delivery :capistrano do
    set :user, $user || 'pi'
    role :raspberrypi, $raspberypis || 'raspberrypi.local', :primary => true
  end
end
