require 'active_tenant'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

TEMP_PATH = ENV['TMP'].gsub("\\", '/')

RSpec.configure do |config|
end