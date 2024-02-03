ENV['APP_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require 'sinatra/activerecord'
require 'rake'
require 'database_cleaner'

# Load the Sinatra application
require File.expand_path('../../app.rb', __FILE__)

module RSpecMixin
  include Rack::Test::Methods
  def app() App end
end

RSpec.configure do |config|
  config.include RSpecMixin

# Configure ActiveRecord for testing
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      database: 'accounts_test',
      username: 'postgres',
      password: 'postgres',
      host: 'localhost',
      port: 5432
    )

    ActiveRecord::Migration.suppress_messages do
      # Run migrations for the test database
      ActiveRecord::MigrationContext.new('db/migrate').migrate
    end
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end