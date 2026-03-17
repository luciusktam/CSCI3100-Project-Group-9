class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("GMAIL_ADDRESS", "noreply@gmail.com")
  layout "mailer"
end
