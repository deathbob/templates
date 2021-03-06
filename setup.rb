# http://m.onkey.org/2008/12/4/rails-templates
# http://www.youvegotrails.com/
# http://railscasts.com/episodes/148-app-templates-in-rails-2-3
# http://github.com/kurbmedia/Rails_Template/raw/master/basic.rb
# http://www.linux-mag.com/cache/7438/1.html
# http://github.com/inmunited/rails_templates
# http://github.com/mbleigh/rails-templates/blob/e9b9f3efebca6d519fa75f029fe899798d7e369d/twitterapp.rb

# example usage 
#
# rails NAME_OF_PROJECT -m PATH_TO_TEMPLATE(CAN BE URL)
# rails templates -m template/setup.rb
#

require 'erb'
require 'net/http'

run "rm public/index.html"
run "cp ~/src/templates/hodel_3000_compliant_logger.rb ./lib/"
run "touch scratch.txt"

app_name = Dir.pwd.split('/').last

# Install and configure capistrano
# run "sudo gem install capistrano" if yes?('Install Capistrano on your local system? (y/n)')
capify!

file 'config/my_deploy_tasks.rb', Net::HTTP.get_response(URI.parse('http://github.com/deathbob/templates/raw/master/my_deploy_tasks.rb')).body

# run 'curl -L http://github.com/inmunited/rails_templates/raw/master/assets/deploy.rb > config/deploy.rb'
file 'config/deploy.rb',  Net::HTTP.get_response(URI.parse('http://github.com/deathbob/templates/raw/master/deploy.rb')).body
file 'config/deploy.yml', Net::HTTP.get_response(URI.parse('http://github.com/deathbob/templates/raw/master/deploy.yml')).body.gsub('app_name', app_name)

if yes?("\nUse MongoDB? (yes/no)")
file 'config/database.yml', <<-CODE
# Using MongoDB
CODE
  environment 'config.frameworks -= [:active_record]'
  gem 'mongo_mapper'
else
  file 'config/database.yml',  Net::HTTP.get_response(URI.parse('http://github.com/deathbob/templates/raw/master/database.yml')).body.gsub("app_name", app_name)
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

plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git' if yes?("Paperclip?")
run "script/plugin install git://github.com/thoughtbot/clearance.git" if yes?("Clearance?")
plugin 'hoptoad_notifier', :git => "git://github.com/thoughtbot/hoptoad_notifier.git"  if yes?("Hoptoad?")
plugin 'oink', :git => 'git://github.com/noahd1/oink.git' 
 
file 'public/javascripts/jquery.js', Net::HTTP.get_response(URI.parse('http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js')).body
file 'public/javascripts/jquery-ui.js', ERB.new(Net::HTTP.get_response(URI.parse('http://jqueryui.com/download/jquery-ui-1.7.1.custom.zip')).body).result(binding)
 
plugin 'jrails', :git => 'git://github.com/jauderho/jrails.git'

initializer 'hoptoad.rb', <<-FILE
  HoptoadNotifier.configure do |config|
  config.api_key = 'HOPTOAD-KEY'
end
FILE

environment <<-HERE
  require 'hodel_3000_compliant_logger'
  config.logger = Hodel3000CompliantLogger.new(config.log_path)
HERE

file 'app/controllers/application_controller.rb', <<-CODE
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include Oink::MemoryUsageLogger
  include Oink::InstanceTypeCounter


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
CODE

 generate :controller, "welcome index"  
 route "map.root :controller => 'welcome'"  


run "git add ."
run "git commit -m 'initial commit'"

rake('gems:install', :sudo => true)
rake('gems:unpack')


puts "***************************************************************"
puts <<-TALKY 
Don't forget to add your hoptoad key to the hoptoad.rb initializer.\n
You need to setup the deploy.yml, particularly the production ip.\n
TALKY
puts "***************************************************************"
