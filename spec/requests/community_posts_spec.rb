require "rails_helper"

RSpec.describe "CommunityPosts", type: :request do
  let(:valid_email) { "poster_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }
  let(:other_email) { "other_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }

  let!(:user) do
    User.create!(
      username: "poster",
      email: valid_email,
      password: "Password123",
      password_confirmation: "Password123",
      email_verified: true,
      verified_at: Time.current
    )
  end

  let!(:other_user) do
    User.create!(
      username: "other",
      email: other_email,
      password: "Password123",
      password_confirmation: "Password123",
      email_verified: true,
      verified_at: Time.current
    )
  end

  let!(:community_post) do
    CommunityPost.create!(
      title: "Hello",
      content: "World",
      user: user
    )
  end

  def login_as(user_obj)
    post login_path, params: { email: user_obj.email, password: "Password123" }
    # Follow redirect to ensure session is set
    follow_redirect! if response.redirect?
  end

  describe "GET /community" do
    it "returns success" do
      get community_path
      expect(response).to have_http_status(:success)
    end

    it "displays posts" do
      get community_path
      expect(response.body).to include("Hello")
    end

    it "filters by search query" do
      post1 = CommunityPost.create!(title: "Ruby on Rails", content: "Great framework", user: user)
      post2 = CommunityPost.create!(title: "Python Tips", content: "Useful tips", user: user)
      get community_path, params: { query: "Rails" }
      expect(response.body).to include("Ruby on Rails")
      expect(response.body).not_to include("Python Tips")
    end

    it "filters by user_id" do
      post1 = CommunityPost.create!(title: "User1 Post", content: "Content1", user: user)
      post2 = CommunityPost.create!(title: "User2 Post", content: "Content2", user: other_user)
      get community_path, params: { user_id: user.id }
      expect(response.body).to include("User1 Post")
      expect(response.body).not_to include("User2 Post")
    end
  end

  describe "GET /community_posts/:id" do
    it "returns success" do
      get community_post_path(community_post)
      expect(response).to have_http_status(:success)
    end

    it "displays post content" do
      get community_post_path(community_post)
      expect(response.body).to include("Hello")
      expect(response.body).to include("World")
    end

    it "shows comment form" do
      get community_post_path(community_post)
      expect(response.body).to include("comment")
    end
  end

  describe "GET /community_posts/new" do
    it "redirects to login when not logged in" do
      get new_community_post_path
      expect(response).to redirect_to(login_path)
    end

    it "returns success when logged in" do
      login_as(user)
      get new_community_post_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /community_posts" do
    it "redirects to login when not logged in" do
      post community_posts_path, params: { community_post: { title: "Test", content: "Content" } }
      expect(response).to redirect_to(login_path)
    end

    it "creates a post when logged in" do
      login_as(user)
      expect {
        post community_posts_path, params: { community_post: { title: "New Post", content: "New Content" } }
      }.to change(CommunityPost, :count).by(1)
      expect(flash[:notice]).to include("created")
    end

    it "fails with invalid params" do
      login_as(user)
      post community_posts_path, params: { community_post: { title: "", content: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /community_posts/:id/edit" do
    it "redirects to login when not logged in" do
      get edit_community_post_path(community_post)
      expect(response).to redirect_to(login_path)
    end

    it "redirects non-owner to community" do
      login_as(other_user)
      get edit_community_post_path(community_post)
      expect(response).to redirect_to(community_path)
    end

    it "returns success for owner" do
      login_as(user)
      get edit_community_post_path(community_post)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /community_posts/:id" do
    it "redirects to login when not logged in" do
      patch community_post_path(community_post), params: { community_post: { title: "Updated" } }
      expect(response).to redirect_to(login_path)
    end

    it "redirects non-owner" do
      login_as(other_user)
      patch community_post_path(community_post), params: { community_post: { title: "Hacked" } }
      expect(response).to redirect_to(community_path)
    end

    it "updates post for owner" do
      login_as(user)
      patch community_post_path(community_post), params: { community_post: { title: "Updated Title", content: "Updated Content" } }
      community_post.reload
      expect(community_post.title).to eq("Updated Title")
    end

    it "fails with invalid params" do
      login_as(user)
      patch community_post_path(community_post), params: { community_post: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /community_posts/:id" do
    it "redirects to login when not logged in" do
      delete community_post_path(community_post)
      expect(response).to redirect_to(login_path)
    end

    it "redirects non-owner" do
      login_as(other_user)
      delete community_post_path(community_post)
      expect(response).to redirect_to(community_path)
      expect(CommunityPost.exists?(community_post.id)).to be true
    end

    it "deletes post for owner" do
      login_as(user)
      delete community_post_path(community_post)
      expect(CommunityPost.exists?(community_post.id)).to be false
      expect(flash[:notice]).to include("deleted")
    end
  end
end
