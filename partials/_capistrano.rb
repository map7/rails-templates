heading "Setup capistrano"

create_file 'config/deploy.rb' do
  <<-eos
set :application, "<app name eg: publishing-solutions>"

# Example         "amanda@localhost:/home/amanda/publishing-solutions"
set :repository,  "<app repo>"

# Local EG:  "10.1.1.10"    # Local LAN address
# Remote EG: "103.1.185.68" # Publishing-solutions MammothVPS
role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# Deployment options
set :deploy_to, "<remote directory>" # EG: "/var/www/pubsol"
set :deploy_via, :copy # This way we don't need port forwarding.

# Remote user info
set :user, "vps"     # VPS is the default MammothVPS user
set :use_sudo, false
default_run_options[:pty] = true

# Version control system 
set :scm, "git"
set :branch, "master"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# Set RVM
# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

# Load RVM's capistrano plugin.    
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2-p290'
set :rvm_type, :system
set :rvm_bin_path, "/usr/local/bin"

# Bundler
namespace :bundler do
  desc "Create a symlink"
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(release_path, '.bundle')
    run("mkdir -p \#\{shared_dir} && ln -s \#\{shared_dir} \#\{release_dir}")
  end

  desc "Install required gems"
  task :install, :roles => :app do
    run "cd \#\{release_path} && bundle install"

    on_rollback do
      if previous_release
        run "cd \#\{previous_release} && bundle install"
      else
        logger.important "no previous release to rollback to, rollback of bundler:install skipped"
      end
    end
  end

  desc "Run bundler on new release"
  task :bundle_new_release, :roles => :db do
    bundler.create_symlink
    bundler.install
  end
end

after "deploy:rollback:revision", "bundler:install"
after "deploy:update_code", "bundler:bundle_new_release"

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "\#\{try_sudo} touch \#\{File.join(current_path,'tmp','restart.txt')}"
   end
 end

eos
end

run 'capify .'

commit "Setup capistrano"
