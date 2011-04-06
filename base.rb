# JS
gem 'jquery-rails'

# View gems
gem 'haml-rails'
gem 'hamlify'
gem 'sass'
gem 'will_paginate', '~> 3.0.pre2'

# Controller


# Debugger
gem 'ruby-debug19'

# Testing gems
gem 'rspec-rails', :group => ["development", "test"]
gem 'capybara', :group => ["development", "test"]
gem 'database_cleaner', :group => ["development", "test"]
gem 'cucumber-rails', :group => ["development", "test"]
gem 'pickle', :group => ["development", "test"]
gem 'spork', :group => "test"
gem 'launchy', :group => "test"    # So you can do Then show me the page
gem 'webrat', :group => "test"     # Testing with JS


gem 'machinist', '>= 2.0.0.beta1'
gem 'faker'

# PDF writer (Used for cucumber reports at the moment).
gem "prawn"

# Devise
if yes?("Would you like to install Devise?")
  gem 'devise'
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'cancan'
  
  generate 'devise:install'

  model_name = ask("What would you like the user model to be called?")
  model_name = "user" if model_name.blank?
  generate 'devise', model_name
  
  generate 'devise:views'
  generate 'cancan:ability'
end

# Put in gems which require git repos.
gem 'inherited_resources', :git => 'https://github.com/josevalim/inherited_resources.git'
gem 'dynamic_form',:git => 'git://github.com/rails/dynamic_form.git'

run 'bundle install'

# Generate stuff
generate 'rspec:install'
generate 'cucumber:install'
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
#generate 'jquery:install'

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
git :commit => "-m 'adding home controller'"


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
