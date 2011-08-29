# Useful variables
# @app_name
# @app_path

# TODO
# Remove second 'User.blueprint' from my blueprints.rb file.

# Fix for Rake 0.9.x
inject_into_file 'Rakefile', :after => "require 'rake'" do
  <<-eos

# Fix for Rake 0.9.x
module ::#{@app_name.classify}
  class Application
    include Rake::DSL
  end
end
 
module ::RakeFileUtils
  extend Rake::FileUtilsExt
end
  eos
end

# JS
gem 'jquery-rails'

# View gems
gem 'haml-rails'
gem 'hamlify'
gem 'sass'
gem 'kaminari' # Better than will_paginate (Cleaner, simplier, more options)
gem 'nifty-generators'
gem 'simple-navigation'

# Debugger
gem 'ruby-debug19'

# Testing gems
gem 'rspec-rails', :group => ["development", "test"]
gem 'capybara', 
  :git => "git://github.com/jnicklas/capybara.git",
  :group => ["development", "test"] # Used instead of webrat

# Setup escape utils which gets rid of the UTF-8 error in testing
gem 'escape_utils'

create_file 'config/initializers/escape_utils.rb' do
  <<-eos
module Rack
  module Utils
    def escape(s)
      EscapeUtils.escape_url(s)
    end
  end
end
  eos
end

#gem 'webrat', :group => "test"                   # Testing with JS
gem 'database_cleaner', :group => ["development", "test"]
gem 'cucumber-rails', :group => ["development", "test"]
gem 'pickle', :group => ["development", "test"]
gem 'spork', :group => "test"
gem 'launchy', :group => "test"    # So you can do Then show me the page
gem 'simplecov'     # Use instead of rcov

gem 'machinist', '>= 2.0.0.beta1'
gem 'faker'

gem 'guard-rspec'        # Run rspec when files change.
gem 'rb-inotify'         # inotify support
gem 'libnotify'        # Notifications

# PDF writer (Used for cucumber reports at the moment).
gem "prawn"

# Put in gems which require git repos.
gem 'inherited_resources', :git => 'https://github.com/josevalim/inherited_resources.git'
gem 'has_scope' # used in conjunction with inherited resources
gem 'dynamic_form',:git => 'git://github.com/rails/dynamic_form.git'

run 'bundle install'

# Generate guard config
run "guard init rspec"

# Generate
generate 'kaminari:config'

# Generate Nice layout using nifty-generator and convert sass to scss.
generate 'nifty:layout --haml'
remove_file 'app/views/layouts/application.html.erb'
generate 'nifty:config'
run 'sass-convert -F sass -T scss public/stylesheets/sass/application.sass public/stylesheets/sass/application.scss'
remove_file 'public/stylesheets/sass/application.sass'

# Generate simple navigation
generate 'navigation_config'

# Generate testing tools
generate 'rspec:install'
generate 'cucumber:install --capybara'
generate 'pickle'

# Machinist install
generate 'machinist:install'
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos


    # Customize generators
    config.generators do |g|
      g.template_engine :haml
      g.fixture_replacement :machinist
    end
  eos
end

inject_into_file 'config/environments/test.rb', :after => 'config.active_support.deprecation = :stderr' do
  <<-eos


  Machinist.configure do |config|
    config.cache_objects = false
  end
  eos
end

# Config machinist to use one blueprints.rb file between cucumber & rspec
create_file 'features/support/machinist.rb' do
  <<-eos
require 'machinist/active_record'
require File.join(File.dirname(__FILE__), '..', '..', 'spec', 'support', 'blueprints.rb')
  eos
end

# Setup some good devise steps for cucumber
create_file 'features/step_definitions/devise_steps.rb' do
  <<-eos
Given /^I am not authenticated$/ do
  visit('/users/sign_out') # ensure that at least
end

Given /^I am logged in as admin$/ do
  admin = User.make!(:admin)

  Given %{I go to the login page}
  And %{I fill in "user_email" with "#\{admin.email\}"}
  And %{I fill in "user_password" with "#\{admin.password\}"}
  And %{I press "Sign in"}
end

Given /^I am logged in as a user$/ do
  user = User.make!

  Given %{I go to the login page}
  And %{I fill in "user_email" with "#\{user.email\}"}
  And %{I fill in "user_password" with "#\{user.password\}"}
  And %{I press "Sign in"}
end
  eos
end

# Setup two blueprints for users
append_file 'spec/support/blueprints.rb' do
  <<-eos
User.blueprint do
  email { 'map7@corsairsolutions.com.au'}
  password { 'password'}
end

User.blueprint(:admin) do
  email { 'michael@dtcorp.com.au'}
  password { 'adminpassword'}
  admin { true }
end
  eos
end


# jQuery install
remove_file 'public/javascripts/rails.js'
generate 'jquery:install'

# Create new git repo.
git :init
git :add => "."
git :commit => "-m 'initial commit'"

# clean up rails defaults
remove_file 'public/index.html'
remove_file 'public/images/rails.png'
run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"


# Add home page
generate :controller, "home index"
route "root :to => 'home#index'"
git :rm => "public/index.html"


git :add => "."
git :commit => "-a -m 'adding home controller'"


# Devise
if yes?("Would you like to install Devise?(yN)")
  gem 'devise'
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'cancan'
  run 'bundle install'
  
  generate 'devise:install'

  model_name = ask("What would you like the user model to be called? (Default: User)")
  model_name = "user" if model_name.blank?
  generate 'devise', model_name
  
  generate 'devise:views'
  generate 'cancan:ability'
  
  # Setup devise
  # Add routes for login/logout
  inject_into_file 'config/routes.rb', :after => 'get "home/index"' do
    <<-eos


  devise_for :users do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
  end

  devise_scope :users do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
  end
    eos
  end

  inject_into_file 'spec/spec_helper.rb', :before => 'RSpec.configure do |config|' do
    <<-eos
def login_admin
  logout_user
  sign_in User.make!(:admin)
end

def login_user
  logout_user
  sign_in User.make!
end

def logout_user
  sign_out :user
end

    eos
  end
end

if yes?("Would you like me to run db create/migrate now?(yN)")
  rake 'db:create'
  rake 'db:migrate'
  rake 'db:test:prepare'
end

say <<-eos
  -------------------------------------------
  Welcome to your new Rails application
 
  Please review what the template has done by scrolling up.

  Where to from here:


  1. Configure your config/database.yml file.

  2. Run the following rake tasks

     $ rake db:create
     $ rake db:migrate
     $ rake db:test:prepare

  3. Enjoy!
eos
