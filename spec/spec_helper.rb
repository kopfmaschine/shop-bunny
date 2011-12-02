# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'shoulda/matchers'
require 'machinist/active_record'
require 'capybara/rails'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Rails.backtrace_cleaner.remove_silencers!

ActiveRecord::Migrator.migrate File.expand_path("../../db/migrate/", __FILE__)
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

class TestSerialNumber
  def self.next
    @counter = (@counter || 0) + rand
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.mock_with :mocha
  config.include ShopBunny::Engine.routes.url_helpers
end