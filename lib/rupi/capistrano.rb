require 'bundler/setup'
require 'sprinkle'

Capistrano::Configuration.instance(:must_exist).load do

  namespace :deploy do
    desc 'prepare your raspberry pi for deployment'
    task :setup do
      sprinkle_path = Gem.find_files('rupi/sprinkle.rb').first
      $user = fetch(:user)
      $raspberypis = find_servers(:roles => :raspberrypi).first.host
      Sprinkle::Script.sprinkle(File.read(sprinkle_path), sprinkle_path)

      run "mkdir -p #{deploy_to}"

      update_code
      bundle
      setup_service
    end

    task :setup_service do
      run "bash -c 'source /etc/profile.d/rvm.sh && rupi_service install #{deploy_to}/app.rb'"
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
      upload(Bundler.root.to_s, "#{deploy_to}", :via => :scp, :recursive => true)
    end

    task :bundle do
      run "bash -c 'source /etc/profile.d/rvm.sh && cd #{deploy_to} && bundle check || bundle install --deployment'"
    end
  end

end
