require "net/smtp"
require "googleauth"

# Custom ActionMailer delivery method that uses Gmail SMTP + OAuth2 (XOAUTH2).
#
# Required env vars:
#   GMAIL_ADDRESS        – the sender Gmail address
#   GOOGLE_CLIENT_ID     – from Google Cloud Console → OAuth 2.0 Client ID
#   GOOGLE_CLIENT_SECRET – same
#   GOOGLE_REFRESH_TOKEN – one-time obtained via OAuth playground (see README)
class GmailOauth2Delivery
  def initialize(settings = {}); end

  def deliver!(mail)
    token = fetch_access_token

    smtp = Net::SMTP.new("smtp.gmail.com", 587)
    smtp.enable_starttls

    smtp.start("gmail.com", ENV.fetch("GMAIL_ADDRESS"), token, :xoauth2) do |conn|
      conn.send_message(mail.encoded, mail.from.first, mail.destinations)
    end
  end

  private

  def fetch_access_token
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id:     ENV.fetch("GOOGLE_CLIENT_ID"),
      client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
      refresh_token: ENV.fetch("GOOGLE_REFRESH_TOKEN"),
      scope:         "https://mail.google.com/"
    )
    credentials.fetch_access_token!
    credentials.access_token
  end
end
