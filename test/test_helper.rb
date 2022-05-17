ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module FixtureFileHelpers
  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
ActiveRecord::FixtureSet.context_class.send :include, FixtureFileHelpers

# helper method for all the test
def login
  post "/logins/create", params: {email: "lxboyjp@gmail.com", password: 'aabbccddeeffgg'}
  follow_redirect!
end
def login_another_user
  post "/logins/create", params: {email: 'foobar@foobar.co.jp', password: 'hhiijjkkllmmnn'}
  follow_redirect!
end
