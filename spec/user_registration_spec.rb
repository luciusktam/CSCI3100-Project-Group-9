require 'rails_helper'

RSpec.describe "User registration", type: :request do
  let(:valid_email) { "newstudent_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }

  describe "GET /register" do
    it "returns http success" do
      get register_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users" do
    it "creates a user with a valid CUHK email" do
      expect do
        post users_path, params: {
          user: {
            email: valid_email,
            username: "cuhkstudent",
            password: "Password123",
            password_confirmation: "Password123"
          }
        }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(login_path)
    end

    it "rejects a non-CUHK email" do
      expect do
        post users_path, params: {
          user: {
            email: "student@gmail.com",
            username: "outsider",
            password: "Password123",
            password_confirmation: "Password123"
          }
        }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Email is invalid")
    end
  end
end
