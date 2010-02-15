# If you need authorisation use this

load_template "http://github.com/map7/rails-templates/raw/master/base.rb"

gem 'authlogic'
rake "gems:install"
git :add => "."
git :commit => "-m 'adding authlogic gem'"

# ask returns a string
name = ask("What do you want your user model to be called? (EG: user, account, client)")
generate :nifty_authentication, name
rake "db:migrate"

git :add => "."
git :commit => "-m 'adding authentication'"

