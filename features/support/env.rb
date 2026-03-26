ENV['RAILS_ENV'] = 'test'
require_relative '../../config/environment'

require 'cucumber/rails'
require 'capybara/rails'
require 'capybara/cucumber'
require 'active_job/test_helper'
ActiveJob::Base.queue_adapter = :test

require 'rspec/expectations'
World(RSpec::Matchers)
World(ActiveJob::TestHelper)

Around do |_scenario, block|
  perform_enqueued_jobs do
    block.call
  end
end

# Isolate scenario state to avoid cross-scenario data and mail/job leakage.
Before do
  Message.destroy_all
  Conversation.destroy_all
  Listing.delete_all
  User.delete_all
  ActionMailer::Base.deliveries.clear
  clear_enqueued_jobs
  clear_performed_jobs
end
