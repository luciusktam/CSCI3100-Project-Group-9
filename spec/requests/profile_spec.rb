require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  describe "GET /profile" do
    it "redirects to login when not signed in" do
      get "/profile"
      expect(response).to redirect_to(login_path)
    end

    it "returns http success when signed in" do
      user = User.create!(
        email: "profile_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "profileuser",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true
      )

      post login_path, params: { email: user.email, password: "Password123" }
      get "/profile"

      expect(response).to have_http_status(:success)
    end
  end
end
