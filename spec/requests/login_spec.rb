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
        email_verified: false
      )
    end

    it "logs in a verified user" do
      post login_path, params: { email: verified_user.email, password: "Password123" }

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(verified_user.id)
    end

    it "rejects an unverified user" do
      post login_path, params: { email: unverified_user.email, password: "Password123" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Your CUHK email has not been verified yet. Please check your email.")
    end

    it "rejects a wrong password" do
      post login_path, params: { email: verified_user.email, password: "WrongPassword123" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Invalid email or password.")
    end
  end

  describe "DELETE /logout" do
    it "logs out the current user" do
      delete logout_path

      expect(response).to redirect_to(root_path)
    end
  end
end
