# http://m.onkey.org/2008/12/4/rails-templates
# http://www.youvegotrails.com/
# http://railscasts.com/episodes/148-app-templates-in-rails-2-3
# http://github.com/kurbmedia/Rails_Template/raw/master/basic.rb
# http://www.linux-mag.com/cache/7438/1.html
# http://github.com/inmunited/rails_templates
# http://github.com/mbleigh/rails-templates/blob/e9b9f3efebca6d519fa75f029fe899798d7e369d/twitterapp.rb

require 'erb'
require 'net/http'

run "rm public/index.html"
run "cp ~/src/templates/hodel_3000_compliant_logger.rb ./lib/"
run "touch scratch.txt"

app_name = Dir.pwd.split('/').last


# Install and configure capistrano
# run "sudo gem install capistrano" if yes?('Install Capistrano on your local system? (y/n)')

capify!

# run 'curl -L http://github.com/inmunited/rails_templates/raw/master/assets/deploy.rb > config/deploy.rb'

file 'config/deploy.rb', Net::HTTP.get_response(URI.parse('http://github.com/inmunited/rails_templates/raw/master/assets/deploy.rb')).body
file 'config/deploy.yml', ERB.new(Net::HTTP.get_response(URI.parse('http://github.com/inmunited/rails_templates/raw/master/assets/deploy.yml')).body).result(binding)

puts "you need to setup the deploy.yml, particularly the production ip"


if yes?("\nUse MongoDB? (yes/no)")
file 'config/database.yml', <<-CODE
# Using MongoDB
CODE
 
  # Don't need ActiveRecord
  environment 'config.frameworks -= [:active_record]'
 
  # MongoMapper
  gem 'mongo_mapper'
end

run "git init"

run "touch .gitignore"

file ".gitignore", <<-END
log/*.*
scratch.txt
tmp/cache/**
*.DS_Store
mkmf.log
END


plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'
run "script/plugin install git://github.com/thoughtbot/clearance.git"
plugin 'hoptoad_notifier', :git => "git://github.com/thoughtbot/hoptoad_notifier.git"

# Install JQuery
 
file 'public/javascripts/jquery.js', Net::HTTP.get_response(URI.parse('http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js')).body
file 'public/javascripts/jquery-ui.js', ERB.new(Net::HTTP.get_response(URI.parse('http://jqueryui.com/download/jquery-ui-1.7.1.custom.zip')).body).result(binding)
 
plugin 'jrails', :git => 'git://github.com/jauderho/jrails.git'
 

initializer 'hoptoad.rb', <<-FILE
HoptoadNotifier.configure do |config|
  config.api_key = 'HOPTOAD-KEY'
end
FILE

puts "puts don't forget to add your hoptoad key to the hoptoad.rb initializer"

env = <<-HERE
  require 'hodel_3000_compliant_logger'
  config.logger = Hodel3000CompliantLogger.new(config.log_path)
HERE

# Finish Up

run "git add ."
run "git commit -m 'initial commit'"


rake('gems:install', :sudo => true)
rake('gems:unpack')

