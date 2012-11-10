require 'bundler/setup'
require 'rupi/version'

Capistrano::Configuration.instance(:must_exist).load do

  set :default_shell, "bash -l"

  namespace :deploy do
    desc 'prepare your raspberry pi for deployment'
    task :setup do
      setup_rvm
      setup_ruby
      setup_rupi

      run "mkdir -p #{deploy_to}"

      update_code
      bundle
      setup_service
    end

    task :setup_rvm do
      run "test -f ~/.rvm/bin/rvm || curl -L get.rvm.io | bash -s stable", :shell => 'sh'
    end

    task :setup_ruby_dependencies do
      run 'sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config'
    end

    task :setup_ruby do
      setup_ruby_dependencies
      put "install: --no-rdoc --no-ri\nupdate: --no-rdoc --no-ri\n", ".gemrc", :via => :scp
      run "rvm mount -r https://s3.amazonaws.com/rvm-pi/debian/wheezy_sid/armv6l/#{Rupi::RUBY_VERSION}.tar.bz2 --verify-downloads 1"
      run "rvm use #{Rupi::RUBY_VERSION} --default"
    end

    task :setup_rupi do
      run 'sudo apt-get -y install uvccapture netatalk avahi-daemon libnss-mdns'
      run 'gem install rupi'
    end

    task :setup_service do
      run "rupi_service install #{deploy_to}/app.rb"
    end

    desc 'deploy the app'
    task :default do
      stop
      update_code
      bundle
      start
    end

    task :stop do
      run "sudo /etc/init.d/rupi_service stop"
    end

    task :start do
      run "sudo /etc/init.d/rupi_service start"
    end

    task :update_code do
      Bundler.root.children.each do |file|
        upload(file.to_s, "#{deploy_to}", :via => :scp, :recursive => true)
      end
    end

    task :bundle do
      run "cd #{deploy_to} && bundle check --without development test || bundle install --without development test"
    end
  end

end
