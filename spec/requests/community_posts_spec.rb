require 'rails_helper'

RSpec.describe "CommunityPosts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/community_posts/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/community_posts/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/community_posts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/community_posts/create"
      expect(response).to have_http_status(:success)
    end
  end

end
