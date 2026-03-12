ENV['RAILS_ENV'] = 'test'
require_relative '../../config/environment'

require 'cucumber/rails'
require 'capybara/rails'
require 'capybara/cucumber'

require 'rspec/expectations'
World(RSpec::Matchers)