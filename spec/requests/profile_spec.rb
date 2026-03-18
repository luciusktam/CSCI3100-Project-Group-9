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

  describe "PATCH /profile" do
    let(:user) do
      User.create!(
        email: "patch_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "patchuser",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true
      )
    end

    it "redirects to login when not signed in" do
      patch "/profile", params: { user: { username: "newname" } }
      expect(response).to redirect_to(login_path)
    end

    it "updates username successfully when signed in" do
      post login_path, params: { email: user.email, password: "Password123" }
      
      expect {
        patch "/profile", params: { user: { username: "newusername" } }
      }.to change { user.reload.username }.to("newusername")
      
      expect(response).to redirect_to(profile_path)
    end

    it "rejects invalid username (blank)" do
      post login_path, params: { email: user.email, password: "Password123" }
      
      patch "/profile", params: { user: { username: "" } }
      
      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.username).not_to eq("")
    end

    it "handles avatar upload (valid image)" do
      post login_path, params: { email: user.email, password: "Password123" }
      
      # Create a temporary file with minimal PNG content
      require 'tempfile'
      temp_file = Tempfile.new(['test', '.png'], encoding: 'ASCII-8BIT')
      temp_file.write("\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82")
      temp_file.rewind
      
      image = Rack::Test::UploadedFile.new(temp_file, "image/png")
      
      patch "/profile", params: { user: { avatar: image } }
      
      expect(user.reload.avatar).to be_attached
      expect(response).to redirect_to(profile_path)
      
      temp_file.close
      temp_file.unlink
    end
  end

  describe "DELETE /profile" do
    let(:user) do
      User.create!(
        email: "delete_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "deleteuser",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true
      )
    end

    it "redirects to login when not signed in" do
      delete delete_profile_path
      expect(response).to redirect_to(login_path)
    end

    it "deletes the user account when signed in" do
      post login_path, params: { email: user.email, password: "Password123" }
      user_id = user.id
      
      delete delete_profile_path
      
      expect(User.find_by(id: user_id)).to be_nil
      expect(response).to redirect_to(root_path)
    end

    it "clears the session after deletion" do
      post login_path, params: { email: user.email, password: "Password123" }
      
      expect(session[:user_id]).to eq(user.id)
      
      delete delete_profile_path
      
      expect(session[:user_id]).to be_nil
    end
  end
end
