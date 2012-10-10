Sprinkle::Installers::Apt.class_eval do
	alias_method :install_commands_original, :install_commands

	def install_commands
		"sudo #{install_commands_original}"
	end
end


package :rvm do
  description 'Ruby Version Manager'

  noop do
    pre :install, 'curl -L https://get.rvm.io | bash -s stable'
  end

  verify do
  	has_file '~/.rvm/bin/rvm'
  end
end

package :ruby_dependencies do
	apt 'build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config'
end

package :ruby do
	description 'Ruby 1.9.3'
	version 'ruby-1.9.3-p194'
	requires :rvm
	requires :ruby_dependencies

	noop do
		pre :install, '~/.rvm/bin/rvm install ruby-1.9.3-p194'
		post :install, '~/.rvm/bin/rvm use ruby-1.9.3-p194 --default'
	end

	verify do
    has_executable '~/.rvm/rubies/ruby-1.9.3-p194/bin/ruby'
  end
end

package :rupi do
	description 'Rupi'
  requires :rvm
	requires :ruby

	apt 'uvccapture'

	noop do
		pre :install, '~/.rvm/bin/gem install rupi --no-rdoc --no-ri'
	end

	verify do
		has_executable '~/.rvm/gems/ruby-1.9.3-p194/bin/rupi'
		has_executable 'uvccapture'
	end
end

policy :rupi, :roles => :raspberrypi do
  requires :rupi
end

deployment do
	delivery :capistrano do
		set :user, 'pi'
		role :raspberrypi, 'raspberrypi.local', :primary => true
		recipes 'deploy'
	end
end
