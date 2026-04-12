require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:user) do
    User.create!(
      email: "commenter@link.cuhk.edu.hk",
      username: "commenter",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  let(:post) do
    CommunityPost.create!(
      title: "Test Post",
      content: "Test content",
      user: user
    )
  end

  let(:valid_attributes) do
    { body: "This is a comment.", community_post: post, user: user }
  end

  describe "validations" do
    it "is valid with a body" do
      comment = described_class.new(valid_attributes)
      expect(comment).to be_valid
    end

    it "is invalid without body" do
      comment = described_class.new(body: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to a community_post" do
      association = described_class.reflect_on_association(:community_post)
      expect(association.macro).to eq :belongs_to
    end

    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end
end
