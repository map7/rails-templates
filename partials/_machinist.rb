# Setup machinist

# Machinist install
heading "Setup machinist"
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

# Config machinist to use one blueprints.rb file between cucumber & rspec
copy_static_file 'features/support/machinist.rb'

# Setup some good devise steps for cucumber
copy_static_file 'features/step_definitions/devise_steps.rb'

commit "Setup machinist"
