require Rails.root.join("lib/gmail_oauth2_delivery")

# Register the custom delivery method once during boot so all environments can
# safely set delivery_method = :gmail_oauth2 without "Invalid delivery method".
ActionMailer::Base.add_delivery_method :gmail_oauth2, GmailOauth2Delivery