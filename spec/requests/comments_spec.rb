require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:user) do
    User.create!(
      username: "tester",
      email: "tester@link.cuhk.edu.hk",
      password: "password",
      email_verified: true
    )
  end

  let(:post_user) do
    User.create!(
      username: "owner",
      email: "owner@link.cuhk.edu.hk",
      password: "password",
      email_verified: true
    )
  end

  let(:community_post) do
    CommunityPost.create!(
      title: "Post",
      content: "Hello",
      user: post_user
    )
  end

  before do
    post login_path, params: {
      email: user.email,
      password: "password"
    }

    expect(response).to redirect_to(root_path)
  end

  describe "POST /community_posts/:community_post_id/comments" do
    it "creates a comment with valid body" do
      expect {
        post community_post_comments_path(community_post), params: {
          comment: { body: "Nice post" }
        }
      }.to change(Comment, :count).by(1)
    end

    it "does not create a comment with blank body" do
      expect {
        post community_post_comments_path(community_post), params: {
          comment: { body: "" }
        }
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /community_posts/:community_post_id/comments/:id" do
    it "deletes own comment" do
      comment = Comment.create!(
        body: "Mine",
        user: user,
        community_post: community_post
      )

      expect {
        delete community_post_comment_path(community_post, comment)
      }.to change(Comment, :count).by(-1)
    end
  end
end
