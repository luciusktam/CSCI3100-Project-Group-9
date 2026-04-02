require "rails_helper"

RSpec.describe "CommunityPosts", type: :request do
  let(:valid_email) { "poster@link.cuhk.edu.hk" }

  let(:user) do
    User.create!(
      username: "poster",
      email: valid_email,
      password: "password"
    )
  end

  let(:community_post) do
    CommunityPost.create!(
      title: "Hello",
      content: "World",
      user: user
    )
  end

  describe "GET /community" do
    it "returns success" do
      get community_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /community_posts/:id" do
    it "returns success" do
      get community_post_path(community_post)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /community_posts/new" do
    it "redirects to login when not logged in" do
      get new_community_post_path
      expect(response).to redirect_to(login_path)
    end
  end
end
