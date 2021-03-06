#
# map7 rails-templates
#
# Usage:
#   rails new appname -d postgesql -m /path/to/base.rb
#
# Useful variables
#   @app_name
#   @app_path
#
# TODO
#   Remove second 'User.blueprint' from my blueprints.rb file.
#
# Ref: http://textmate.rubyforge.org/thor/Thor/Actions.html
# Ref: https://github.com/bsleys/hobo-rails-template/blob/master/template.rb

# Directories for template partials and static files
@template_root = File.expand_path(File.join(File.dirname(__FILE__)))
@partials = File.join(@template_root, 'partials')
@static_files = File.join(@template_root, 'files')

# Copy a static file from the template into the new application
def copy_static_file(path)
  puts "Installing #{path}...".yellow
  remove_file path
  file path, File.read(File.join(@static_files, path))
end

def heading(title)
  puts "\n\n========================================================="
  puts " #{title}".yellow.bold
  puts "=========================================================\n\n"
end

def commit(message)
  git :init unless File.directory?('.git')
  git :add => '.'
  git :commit => "-aqm '#{message}'"
end

# Setup color
unless Gem.available?('colored')
  run "gem install colored"
  Gem.refresh
  Gem.activate('colored')
end

require "colored"
heading "Starting map7 rails template"

# Create new git repo.
commit 'initial commit'

# Ask configure questions now
heading "Configure"
@install_devise = yes?("Would you like to install Devise?(yN)")
@devise_model = ask("What would you like the user model to be called? (Default: User)") if @install_devise
@setup_home = yes?("Would you like a home controller setup(yN)")
@migrate_at_end = yes?("Would you like me to run db create/migrate now?(yN)")

copy_static_file "Gemfile"
commit "Copied Gemfile"

# Setup escape utils which gets rid of the UTF-8 error in testing
heading "Fix UTF-8 error in testing"
copy_static_file 'config/initializers/escape_utils.rb' 
commit "Fix UTF-8 error"

# Guard config
heading "Config guard config"
run "guard init rspec"
commit "Setup guard"

# Run bundle
heading "Bundle install"
run 'bundle install'

# Setup pagination
heading "Kaminari setup"
generate 'kaminari:config'
commit "Setup pagination"

# Could be cause of many issues.
# # Generate Nice layout using nifty-generator and convert sass to scss.
# heading "Setup layout"
# generate 'nifty:layout --haml'
# remove_file 'app/views/layouts/application.html.erb'
# generate 'nifty:config'
# commit "Setup layout"

# Convert application.css to sass
# heading "Config SASS"
# run 'sass-convert -F sass -T scss app/assets/stylesheets/sass/application.sass app/assets/stylesheets/sass/application.scss'
# remove_file 'app/assets/stylesheets/sass/application.sass'

# Generate simple navigation
heading "Setup nav"
generate 'navigation_config'
commit "Setup Navigation"

# Generate testing tools
heading "Setup testing tools"
generate 'rspec:install'
generate 'cucumber:install --capybara'
generate 'pickle'
commit "Setup Testing tools"

apply "#{@partials}/_rack.rb"       # Fix Rack
apply "#{@partials}/_machinist.rb"  # Setup machinist
apply "#{@partials}/_devise.rb"     # Setup devise
apply "#{@partials}/_capistrano.rb" # Setup capistrano

# Add home page
heading "Setup home controller"
if @setup_home
  generate :controller, "home index"
  route "root :to => 'home#index'"
  commit 'adding home controller'
end

# clean up rails defaults
heading "Clean up rails defaults"
remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'
commit "Clean up rails defaults"

# DB migration
if @migrate_at_end
  heading "Run migrate"
  rake 'db:create'
  rake 'db:migrate'
  rake 'db:test:prepare'
end

# Adding example of postgresql to database.yml
heading "Adding postgresql example to database.yml"
append_file 'config/database.yml' do
  <<-eos

#
# Refer to your chef script for user & password settings
#
# production:
#   adapter: postgresql
#   encoding: unicode
#   database: #{@app_name}_production
#   pool: 5
#   username: <user>
#   password: <password>

# cucumber:
#   <<: *test

eos
end
commit "Add postgres example to database.yml"

heading "Installation complete!"
say <<-eos
  -------------------------------------------
  Welcome to your new Rails application
 
  Please review what the template has done by scrolling up.

  Where to from here:


  1. Configure your config/database.yml file.

  2. Run the following rake tasks (must be done before deploy)

     $ rake db:create
     $ rake db:migrate
     $ rake db:test:prepare

  3. Enjoy!

  Deploy notes:
  -----------------------------------------------------------------------------------
  - Check that my database.yml settings are the same as the dbuser & dbpass in chef.
  - Check the deploy.rb file

  First time deploy
  - cap deploy:setup
  - cap deploy:cold

  Run seed (Run last after everything is setup ie: sphinx search)
  - cap deploy:seed

  Edit config on server
  - Edit the /etc/apache2/sites-enabled/rails_project on your server
  - sudo service apache2 restart

  Sphinx notes:
  -----------------------------------------------------------------------------------
  Uncomment the sphinx lines in deploy.rb

  Sphinx, you may have to do a standard cap deploy
  - cap deploy

  Heroku deploy
  -----------------------------------------------------------------------------------

  - Add heroku to Gemfile & bundle install
  - Create heroku stack
  % heroku create --stack cedar

  - Config your project to use postgresql & commit change
  : gem 'pg'
  : group :development, :test do
  :         gem 'sqlite3'
  : end


  Now deploy your app to heroku
  : % git push heroku master 

  Run db:migrate on heroku server
  : % heroku run rake db:migrate

  Restart server
  : % heroku restart

eos
