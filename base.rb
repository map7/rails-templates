# ryanb's layout tool.
generate :nifty_layout

# View gems
gem 'will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'


# Testing gems
gem 'rspec-rails', :group => "test"
gem 'cucumber-rails', :group => "test"

# Devise
if yes?("Would you like to install Devise?")
  gem 'devise'
  generate 'devise:install'

  model_name = ask("What would you like the user model to be called?")
  model_name = "user" if model_name.blank?
  generate 'devise', model_name
end

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
