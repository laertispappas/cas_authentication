$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
Bundler.setup

require 'api'
require "database_cleaner"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/test.sqlite3'
)

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

#  config.around(:each) do |example|
#    DatabaseCleaner.cleaning do
#      example.run
#    end
#  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  def spawn_user email: 'me@example.com', password: 'password'
    service = Api::Services::Signup.new email: email, password: password
    service.call
    service.user
  end

  def spawn_login_ticket
    service = Api::Services::Login.new
    service.call
    service.ticket
  end

  def spawn_ticket_granting_ticket user
    tgt = TicketGrantingTicket.new name: 'TGT-random', user: user
    tgt.save
    tgt
  end
end
