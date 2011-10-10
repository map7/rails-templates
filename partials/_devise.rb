heading "Setup Devise"

# Devise
if @install_devise
  gem 'devise'
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'cancan'
  run 'bundle install'
  
  generate 'devise:install'

  @devise_mode = "user" if @devise_mode.blank?
  generate 'devise', @devise_mode
  
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

  commit "Setup Devise"
end

