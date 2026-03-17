require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#verification_email" do
    let(:user) do
      User.new(
        email:              "student@link.cuhk.edu.hk",
        username:           "testuser",
        verification_token: "tok_abc123XYZ"
      )
    end

    subject(:mail) { described_class.verification_email(user) }

    it "sends to the user's email address" do
      expect(mail.to).to eq(["student@link.cuhk.edu.hk"])
    end

    it "uses the configured sender address" do
      expect(mail.from).to include(ENV.fetch("GMAIL_ADDRESS", "noreply@gmail.com"))
    end

    it "sets the correct subject" do
      expect(mail.subject).to eq("CUMarket \u2013 Verify your CUHK email address")
    end

    it "includes the verification token in the email body" do
      expect(mail.body.encoded).to include("tok_abc123XYZ")
    end

    it "includes a /verify/ link in the body" do
      expect(mail.body.encoded).to include("/verify/")
    end
  end
end
