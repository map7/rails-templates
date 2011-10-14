heading "Setup capistrano"

create_file 'config/deploy.rb' do
  <<-eos
# require 'thinking_sphinx/deploy/capistrano'

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
set :deploy_to, "<remote directory>" # EG: "/srv/pubsol"
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

# # Thinking Sphinx
# task :before_update_code, :roles => [:app] do
#   thinking_sphinx.stop if File.exists?(current_path)
#   unless File.exists?("\#\{shared_path}/db") or File.exists?("\#\{shared_path}/tmp")
#     run("mkdir -p \#\{shared_path}/db")
#     run("mkdir -p \#\{shared_path}/tmp")
#   end
# end
#
# task :after_update_code, :roles => [:app] do
#   deploy.migrate
#   symlink_sphinx_indexes
#   thinking_sphinx.configure
#   thinking_sphinx.index
#   thinking_sphinx.stop
#   thinking_sphinx.start
# end
#
# task :symlink_sphinx_indexes, :roles => [:app] do
#   run "ln -nfs \#\{shared_path}/db/sphinx \#\{release_path}/db/sphinx"
# end



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

before "deploy:assets:precompile", "bundler:install"
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


namespace :deploy do
  desc "Seed DB defaults into production server."
  task :seed do
    run "cd \#\{current_path}; RAILS_ENV=production rake db:seed"    
  end
  
  desc "Deploy and load the DB from the schema file."
  task :cold do       # Overriding the default deploy:cold
    update
    load_schema       # My own step, replacing migrations.
    start
  end

  task :load_schema, :roles => :app do
    run "cd \#\{current_path}; RAILS_ENV=production rake db:create"
    run "cd \#\{current_path}; RAILS_ENV=production rake db:schema:load"
  end
end

eos
end

create_file 'Capfile' do 
  <<-eos
# load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks%    
eos
end

create_file 'config/sphinx.yml' do
  <<-eos
development:
  enable_star: false
  min_prefix_len: 3

production:
  pid_file: /srv/\#\{@app_name}/shared/tmp/searchd.pid
  searchd_file_path: /srv/\#\{@app_name}/shared/db/sphinx
  min_prefix_len: 3
  max_matches: 10000

cucumber:
  port: <%= 9313 + ENV['TEST_ENV_NUMBER'].to_i %>
  searchd_file_path: <%= "\#\{Rails.root}/db/sphinx/sphinx.\#\{ENV['TEST_ENV_NUMBER'].to_i}" %>
  config_file: <%= "\#\{Rails.root}/config/cucumber.\#\{ENV['TEST_ENV_NUMBER'].to_i}.sphinx.conf" %>
  searchd_log_file: <%= "\#\{Rails.root}/log/searchd.\#\{ENV['TEST_ENV_NUMBER'].to_i}.log" %>
  query_log_file: <%= "\#\{Rails.root}/log/searchd.query.\#\{ENV['TEST_ENV_NUMBER'].to_i}.log" %>
  pid_file: <%= "\#\{Rails.root}/log/searchd.\#\{ENV['TEST_ENV_NUMBER'].to_i}.pid" %>

eos
end

# No longer have to run this
# run 'capify .'

commit "Setup capistrano"
