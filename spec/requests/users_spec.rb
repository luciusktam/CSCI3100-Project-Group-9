require "rails_helper"

RSpec.describe "Email verification flow", type: :request do
  include ActiveJob::TestHelper

  before do
    ActionMailer::Base.deliveries.clear
    clear_enqueued_jobs
    clear_performed_jobs
  end

  let(:verification_token) { SecureRandom.hex(32) }

  let!(:user) do
    User.create!(
      email:              "verify_test_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
      username:           "verifytest",
      password:           "Password123",
      password_confirmation: "Password123",
      verification_token: verification_token,
      email_verified:     false,
      verification_sent_at: Time.current
    )
  end

  describe "GET /verify/:user_id/:token" do
    context "with a valid, unused token" do
      it "renders the confirmation page without verifying the user" do
        get verify_email_path(user_id: user.id, token: verification_token)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Verify Your Email")
        expect(user.reload.email_verified).to be false
      end
    end

    context "when the token has already been used (token cleared)" do
      before { user.update!(email_verified: true, verified_at: Time.current, verification_token: nil) }

      it "redirects to root with an invalid-link message" do
        get verify_email_path(user_id: user.id, token: verification_token)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Invalid or expired verification link.")
      end
    end

    context "with an invalid token" do
      it "redirects to the home page with an error" do
        get verify_email_path(user_id: user.id, token: "nonexistent_token")
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Invalid or expired verification link.")
      end
    end
  end

  describe "POST /verify/:user_id/:token (confirm_verify)" do
    context "with a valid, unused token" do
      it "marks the user as verified and redirects to login" do
        post confirm_verify_email_path(user_id: user.id, token: verification_token)
        expect(response).to redirect_to(login_path)
        expect(user.reload.email_verified).to be true
        expect(user.reload.verified_at).not_to be_nil
      end

      it "clears the verification token after use" do
        post confirm_verify_email_path(user_id: user.id, token: verification_token)
        expect(user.reload.verification_token).to be_nil
      end

      it "shows a success flash message" do
        post confirm_verify_email_path(user_id: user.id, token: verification_token)
        follow_redirect!
        expect(response.body).to include("Email verified! You can now log in.")
      end
    end

    context "when the token has already been used" do
      before { user.update!(email_verified: true, verified_at: Time.current, verification_token: nil) }

      it "redirects to root with an invalid-link message" do
        post confirm_verify_email_path(user_id: user.id, token: verification_token)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Invalid or expired verification link.")
      end
    end

    context "with an invalid token" do
      it "redirects to root with an invalid-link message" do
        post confirm_verify_email_path(user_id: user.id, token: "nonexistent_token")
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
        perform_enqueued_jobs do
          post users_path, params: {
            user: {
              email:                 recipient_email,
              username:              "newreguser",
              password:              "Password123",
              password_confirmation: "Password123"
            }
          }
        end
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sends the verification email to the registered address" do
      recipient_email = "newreg2_#{SecureRandom.hex(4)}@link.cuhk.edu.hk"

      perform_enqueued_jobs do
        post users_path, params: {
          user: {
            email:                 recipient_email,
            username:              "newreguser2",
            password:              "Password123",
            password_confirmation: "Password123"
          }
        }
      end

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(recipient_email)
      expect(email.subject).to include("Verify your CUHK email address")
    end
  end
end
