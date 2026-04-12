require "rails_helper"
require_relative "../../lib/gmail_oauth2_delivery"

RSpec.describe GmailOauth2Delivery do
  let(:delivery) { described_class.new }
  let(:test_token) { "test_access_token_123" }

  # Create a test mail object
  let(:test_mail) do
    Mail::TestMailer.deliveries.clear
    mail = Mail.new do
      from    "sender@gmail.com"
      to      "recipient@example.com"
      subject "Test Subject"
      body    "Test Body"
    end
    mail
  end

  before do
    # Set required environment variables for testing
    ENV["GMAIL_ADDRESS"] = "test@gmail.com"
    ENV["GOOGLE_CLIENT_ID"] = "test_client_id"
    ENV["GOOGLE_CLIENT_SECRET"] = "test_client_secret"
    ENV["GOOGLE_REFRESH_TOKEN"] = "test_refresh_token"
  end

  after do
    # Clean up environment variables
    ENV.delete("GMAIL_ADDRESS")
    ENV.delete("GOOGLE_CLIENT_ID")
    ENV.delete("GOOGLE_CLIENT_SECRET")
    ENV.delete("GOOGLE_REFRESH_TOKEN")
  end

  describe "#initialize" do
    it "accepts settings hash" do
      expect { described_class.new(timeout: 30) }.not_to raise_error
    end

    it "works with no arguments" do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe "#deliver!" do
    context "when SMTP connection succeeds" do
      let(:smtp_double) { instance_double("Net::SMTP") }

      before do
        # Stub the fetch_access_token method
        allow(delivery).to receive(:fetch_access_token).and_return(test_token)

        # Mock Net::SMTP
        allow(Net::SMTP).to receive(:new).and_return(smtp_double)
        allow(smtp_double).to receive(:enable_starttls)
        allow(smtp_double).to receive(:start).and_yield(smtp_double)
        allow(smtp_double).to receive(:send_message)
      end

      it "fetches access token" do
        delivery.deliver!(test_mail)
        expect(delivery).to have_received(:fetch_access_token)
      end

      it "creates SMTP connection to Gmail" do
        delivery.deliver!(test_mail)
        expect(Net::SMTP).to have_received(:new).with("smtp.gmail.com", 587)
      end

      it "enables STARTTLS" do
        delivery.deliver!(test_mail)
        expect(smtp_double).to have_received(:enable_starttls)
      end

      it "starts SMTP session with OAuth2 authentication" do
        delivery.deliver!(test_mail)
        expect(smtp_double).to have_received(:start).with("gmail.com", "test@gmail.com", test_token, :xoauth2)
      end

      it "sends the message" do
        delivery.deliver!(test_mail)
        expect(smtp_double).to have_received(:send_message).with(
          test_mail.encoded,
          test_mail.from.first,
          test_mail.destinations
        )
      end

      it "returns without error" do
        expect { delivery.deliver!(test_mail) }.not_to raise_error
      end
    end

    context "when SMTP connection fails" do
      before do
        allow(delivery).to receive(:fetch_access_token).and_return(test_token)
        allow(Net::SMTP).to receive(:new).and_raise(Net::SMTPFatalError.new("Connection refused"))
      end

      it "raises the SMTP error" do
        expect { delivery.deliver!(test_mail) }.to raise_error(Net::SMTPFatalError)
      end
    end

    context "when token fetch fails" do
      before do
        allow(delivery).to receive(:fetch_access_token).and_raise(StandardError.new("Token refresh failed"))
      end

      it "propagates the authentication error" do
        expect { delivery.deliver!(test_mail) }.to raise_error(StandardError, "Token refresh failed")
      end
    end
  end

  describe "#fetch_access_token (private)" do
    it "creates Google::Auth::UserRefreshCredentials with correct parameters" do
      expect(Google::Auth::UserRefreshCredentials).to receive(:new).with(
        client_id:     "test_client_id",
        client_secret: "test_client_secret",
        refresh_token: "test_refresh_token",
        scope:         "https://mail.google.com/"
      ).and_call_original

      # Access private method via send
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:fetch_access_token!)
      delivery.send(:fetch_access_token)
    end

    it "fetches and returns access token" do
      credentials_double = instance_double("Google::Auth::UserRefreshCredentials")
      allow(Google::Auth::UserRefreshCredentials).to receive(:new).and_return(credentials_double)
      allow(credentials_double).to receive(:fetch_access_token!)
      allow(credentials_double).to receive(:access_token).and_return("returned_token")

      result = delivery.send(:fetch_access_token)
      expect(result).to eq("returned_token")
    end

    context "when credentials are missing" do
      before do
        ENV.delete("GOOGLE_CLIENT_ID")
        ENV.delete("GOOGLE_CLIENT_SECRET")
        ENV.delete("GOOGLE_REFRESH_TOKEN")
      end

      it "raises KeyError for missing GOOGLE_CLIENT_ID" do
        expect { delivery.send(:fetch_access_token) }.to raise_error(KeyError)
      end
    end
  end
end
