require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  describe "GET /forgot_password" do
    it "returns http success" do
      get "/forgot_password"
      expect(response).to have_http_status(:success)
    end

    it "displays forgot password form" do
      get "/forgot_password"
      expect(response.body).to include("Forgot password")
      expect(response.body).to include("Send reset link")
    end
  end

  describe "POST /forgot_password" do
    let(:user) do
      User.create!(
        email: "forgot_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "forgotuser",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true
      )
    end

    it "generates password reset token and token is stored as digest" do
      post "/forgot_password", params: { email: user.email }
      
      user.reload
      expect(user.reset_password_token_digest).to be_present
      expect(user.reset_password_sent_at).to be_present
      expect(response).to redirect_to(login_path)
    end

    it "enqueues password reset email for existing user" do
      expect {
        post "/forgot_password", params: { email: user.email }
      }.to have_enqueued_job.on_queue("default")
      
      expect(response).to redirect_to(login_path)
    end

    it "does not leak user existence" do
      post "/forgot_password", params: { email: user.email }
      notice1 = flash[:notice]
      
      post "/forgot_password", params: { email: "nonexistent_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }
      notice2 = flash[:notice]
      
      expect(notice1).to eq(notice2)
    end
  end

  describe "GET /reset_password/:token" do
    let(:user) do
      User.create!(
        email: "reset_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "resetuser",
        password: "OldPassword123",
        password_confirmation: "OldPassword123",
        email_verified: true
      )
    end

    it "returns success with a valid token" do
      token = user.generate_password_reset_token!
      user.update!(reset_password_sent_at: Time.current)
      
      get "/reset_password/#{token}"
      
      expect(response).to have_http_status(:success)
    end

    it "rejects an invalid token" do
      get "/reset_password/invalid_token_12345"
      
      expect(response).to redirect_to(forgot_password_path)
      expect(flash[:alert]).to include("Invalid reset link")
    end

    it "rejects an expired token (older than 30 minutes)" do
      token = user.generate_password_reset_token!
      user.update!(reset_password_sent_at: 31.minutes.ago)
      
      get "/reset_password/#{token}"
      
      expect(response).to redirect_to(forgot_password_path)
      expect(flash[:alert]).to include("expired")
    end
  end

  describe "PATCH /reset_password/:token" do
    let(:user) do
      User.create!(
        email: "patch_reset_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "patchresetuser",
        password: "OldPassword123",
        password_confirmation: "OldPassword123",
        email_verified: true
      )
    end

    before do
      @token = user.generate_password_reset_token!
      user.update!(reset_password_sent_at: Time.current)
    end

    it "updates password successfully with valid token" do
      new_password = "NewPassword456"
      
      patch "/reset_password/#{@token}", params: {
        user: { password: new_password, password_confirmation: new_password }
      }
      
      expect(user.reload.authenticate(new_password)).to be_truthy
      expect(user.reset_password_token_digest).to be_nil
      expect(response).to redirect_to(login_path)
    end

    it "rejects mismatched password confirmation" do
      patch "/reset_password/#{@token}", params: {
        user: { password: "NewPassword456", password_confirmation: "DifferentPassword789" }
      }
      
      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.authenticate("OldPassword123")).to be_truthy
    end

    it "rejects password shorter than 8 characters" do
      patch "/reset_password/#{@token}", params: {
        user: { password: "Short1", password_confirmation: "Short1" }
      }
      
      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.authenticate("OldPassword123")).to be_truthy
    end

    it "rejects an invalid token" do
      patch "/reset_password/invalid_token", params: {
        user: { password: "NewPassword456", password_confirmation: "NewPassword456" }
      }
      
      expect(response).to redirect_to(forgot_password_path)
      expect(user.reload.authenticate("OldPassword123")).to be_truthy
    end

    it "rejects an expired token" do
      user.update!(reset_password_sent_at: 31.minutes.ago)
      
      patch "/reset_password/#{@token}", params: {
        user: { password: "NewPassword456", password_confirmation: "NewPassword456" }
      }
      
      expect(response).to redirect_to(forgot_password_path)
      expect(flash[:alert]).to include("expired")
      expect(user.reload.authenticate("OldPassword123")).to be_truthy
    end

    it "clears token after successful reset (prevents token reuse)" do
      new_password = "NewPassword456"
      
      patch "/reset_password/#{@token}", params: {
        user: { password: new_password, password_confirmation: new_password }
      }
      
      user.reload
      expect(user.reset_password_token_digest).to be_nil
      
      # Attempting to use the same token again should fail
      patch "/reset_password/#{@token}", params: {
        user: { password: "AnotherPassword789", password_confirmation: "AnotherPassword789" }
      }
      
      expect(response).to redirect_to(forgot_password_path)
    end
  end
end
