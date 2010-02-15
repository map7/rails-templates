run "echo TODO > README"

# ryanb's layout tool.
generate :nifty_layout

# Install gems
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
rake "gems:install"

# Create new git repo.
git :init

# Install plugins
plugin "wheres-your-database-yml-dude", :git => "git://github.com/technicalpickles/wheres-your-database-yml-dude"

plugin "shortcuts", :git => "git://github.com/map7/shortcuts.git"
generate("shortcuts")


file ".gitignore", <<-END
coverage/*
*.cache
#*
.#*
*~
*.log
*.pid
tmp/**/*
.DS_Store
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/database.yml.example"

git :add => "."
git :commit => "-m 'initial commit'"


generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"

git :add => "."
git :commit => "-m 'adding welcome controller'"
