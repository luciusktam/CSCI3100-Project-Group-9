require "rails_helper"

RSpec.describe "Email verification flow", type: :request do
  before do
    ActionMailer::Base.deliveries.clear
  end

  let(:verification_token) { SecureRandom.hex(32) }

  let!(:user) do
    User.create!(
      email:              "verify_test_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
      username:           "verifytest",
      password:           "Password123",
      password_confirmation: "Password123",
      verification_token: verification_token,
      email_verified:     false
    )
  end

  describe "GET /verify/:token" do
    context "with a valid, unused token" do
      it "marks the user as verified and redirects to login" do
        get verify_email_path(token: verification_token)
        expect(response).to redirect_to(login_path)
        expect(user.reload.email_verified).to be true
        expect(user.reload.verified_at).not_to be_nil
      end

      it "clears the verification token after use" do
        get verify_email_path(token: verification_token)
        expect(user.reload.verification_token).to be_nil
      end

      it "shows a success flash message" do
        get verify_email_path(token: verification_token)
        follow_redirect!
        expect(response.body).to include("Email verified! You can now log in.")
      end
    end

    context "when the token has already been used" do
      before { user.update!(email_verified: true, verified_at: Time.current, verification_token: nil) }

      it "redirects to login with an already-verified message" do
        get verify_email_path(token: verification_token)
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Email already verified.")
      end
    end

    context "with an invalid token" do
      it "redirects to the home page with an error" do
        get verify_email_path(token: "nonexistent_token")
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Invalid or expired verification link.")
      end
    end
  end

  describe "POST /users (registration triggers email)" do
    it "enqueues a verification email on successful registration" do
      recipient_email = "newreg_#{SecureRandom.hex(4)}@link.cuhk.edu.hk"

      expect {
        post users_path, params: {
          user: {
            email:                 recipient_email,
            username:              "newreguser",
            password:              "Password123",
            password_confirmation: "Password123"
          }
        }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sends the verification email to the registered address" do
      recipient_email = "newreg2_#{SecureRandom.hex(4)}@link.cuhk.edu.hk"

      post users_path, params: {
        user: {
          email:                 recipient_email,
          username:              "newreguser2",
          password:              "Password123",
          password_confirmation: "Password123"
        }
      }
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(recipient_email)
      expect(email.subject).to include("Verify your CUHK email address")
    end
  end
end
