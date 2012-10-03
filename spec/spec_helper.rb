require 'active_tenant'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

TEMP_PATH = ENV['TMP'].gsub("\\", '/')

ActiveRecord::Migrator.migrations_path = "#{File.dirname(__FILE__)}/migrations"

RSpec.configure do |config|
end