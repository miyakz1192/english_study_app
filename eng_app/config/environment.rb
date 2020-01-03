# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Dir[File.dirname(__FILE__) + '/app/models/view_model/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/app/models/view_model/*.rb'].each {|file| require file }

Dir[File.dirname(__FILE__) + '/app/presenters/*.rb'].each {|file| puts "require #{file}" }
Dir[File.dirname(__FILE__) + '/app/presenters/*.rb'].each {|file| puts "require #{file}" }


#require "./app/models/view_model/user_view_model.rb"
#require "./app/presenter/dashboard_presenter.rb"
