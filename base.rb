# Postgresql
gem 'pg'

# JS
gem 'jquery-rails'

# View gems
gem 'haml-rails'
gem 'sass'
gem 'dynamic_form',:git => 'git://github.com/rails/dynamic_form.git'
gem 'will_paginate', '~> 3.0.pre2'

# Controller
gem 'inherited_resources', :git => 'https://github.com/josevalim/inherited_resources.git'

# Debugger
gem 'ruby-debug19'

# Testing gems
gem 'capybara', :group => "test"
gem 'database_cleaner', :group => "test"
gem 'cucumber-rails', :group => "test"
gem 'pickle', :group => "test"
gem 'rspec-rails', :group => "test"
gem 'spork', :group => "test"
gem 'launchy', :group => "test"    # So you can do Then show me the page
gem 'webrat', :group => "test"


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
end

run 'bundle install'
rake 'db:create', :env => 'development'
rake 'db:create', :env => 'test'

# Generate stuff
generate 'nifty_layout --haml' # ryanb's layout tool.
generate 'jquery:install'
generate 'rspec:install'


# Create new git repo.
git :init
git :add => "."
git :commit => "-m 'initial commit'"

# Add home page
generate :controller, "home index"
route "map.root :controller => 'home'"
git :rm => "public/index.html"

git :add => "."
git :commit => "-m 'adding home controller'"
