# Fix for Rake 0.9.x
heading "Fix for Rake 0.9.x"

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

commit "Fix Rack"
