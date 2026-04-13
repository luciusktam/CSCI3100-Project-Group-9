require 'rails_helper'

RSpec.describe "Logins", type: :request do
  let(:verified_email) { "existing_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }
  let(:unverified_email) { "pending_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }

  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    let!(:verified_user) do
      User.create!(
        email: verified_email,
        username: "existing",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true,
        verified_at: Time.current
      )
    end

    let!(:unverified_user) do
      User.create!(
        email: unverified_email,
        username: "pending",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: false,
        verification_sent_at: Time.current
      )
    end

    it "logs in a verified user" do
      post login_path, params: { email: verified_user.email, password: "Password123" }

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(verified_user.id)
    end

    it "rejects an unverified user" do
      post login_path, params: { email: unverified_user.email, password: "Password123" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Your CUHK email has not been verified yet. Please check your email.")
    end

    it "rejects a wrong password" do
      post login_path, params: { email: verified_user.email, password: "WrongPassword123" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password.")
    end
  end

  describe "DELETE /logout" do
    it "logs out the current user" do
      delete logout_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /verify/resend" do
    let!(:unverified_user) do
      User.create!(
        email: "resend_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "resend_test",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: false,
        verification_token: SecureRandom.hex(32),
        verification_sent_at: Time.current
      )
    end

    it "regenerates token and enqueues email for unverified user" do
      original_token = unverified_user.verification_token
      
      expect {
        post "/verify/resend", params: { email: unverified_user.email }
      }.to change { unverified_user.reload.verification_token }
      
      expect(response).to redirect_to(login_path)
      expect(response).to have_http_status(:found)
    end

    it "does not regenerate token for already verified user" do
      verified_user = User.create!(
        email: "verified_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "verified_test",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true,
        verified_at: Time.current
      )
      
      original_token = verified_user.verification_token
      
      post "/verify/resend", params: { email: verified_user.email }
      
      expect(verified_user.reload.verification_token).to eq(original_token)
      expect(response).to redirect_to(login_path)
    end

    it "does not leak existence of unverified user" do
      post "/verify/resend", params: { email: "nonexistent_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }
      
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to include("If the account exists and is unverified")
    end

    it "does not reveal if email is verified or not" do
      # The response should be identical whether user exists/unverified or doesn't exist
      post "/verify/resend", params: { email: unverified_user.email }
      notice1 = flash[:notice]
      
      post "/verify/resend", params: { email: "nonexistent_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }
      notice2 = flash[:notice]
      
      expect(notice1).to eq(notice2)
    end
  end
end
