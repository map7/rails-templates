Template should include
• all my favourite gems
• jquery installed
• devise configured for user.
• my jquery plugins all configured
• full tests done in cucumber & rspec
• Nice stylesheet done in SCSS for basic website presentation.


References
http://everydayrails.com/2011/02/28/rails-3-application-templates.html
http://blog.madebydna.com/all/code/2010/10/11/cooking-up-a-custom-rails3-template.html
http://guides.rubyonrails.org/generators.html#application-templates
http://railscasts.com/episodes/148-app-templates-in-rails-2-3
http://thelastpixel.net/2010/11/21/rails-3-application-template/

Use this template like so
rails new <project name> -d postgresql -m https://github.com/map7/rails-templates/raw/master/base.rb

TODO
- remark out all lines in navigation.rb
- Add a line to navigation for home page (root_path)
- Add some nav lines to login/logout
- Configure style of nav like my AAD website
- add '= render_navigation :renderer => :links' to application.html.haml
