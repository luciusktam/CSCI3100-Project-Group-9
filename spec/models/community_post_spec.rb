require "rails_helper"

RSpec.describe CommunityPost, type: :model do
  let(:user) do
    User.create!(
      email: "author@link.cuhk.edu.hk",
      username: "author",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  let(:valid_attributes) do
    { title: "Test Post", content: "This is test content.", user: user }
  end

  describe "validations" do
    it "is valid with title and content" do
      post = described_class.new(valid_attributes)
      expect(post).to be_valid
    end

    it "is invalid without title" do
      post = described_class.new(valid_attributes.merge(title: nil))
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it "is invalid without content" do
      post = described_class.new(valid_attributes.merge(content: nil))
      expect(post).not_to be_valid
      expect(post.errors[:content]).to include("can't be blank")
    end

    it "is invalid with title longer than 100 characters" do
      post = described_class.new(valid_attributes.merge(title: "a" * 101))
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("is too long (maximum is 100 characters)")
    end

    it "is valid with title of exactly 100 characters" do
      post = described_class.new(valid_attributes.merge(title: "a" * 100))
      expect(post).to be_valid
    end
  end

  describe "associations" do
    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it "has many comments" do
      association = described_class.reflect_on_association(:comments)
      expect(association.macro).to eq :has_many
    end

    it "destroys dependent comments" do
      post = described_class.create!(valid_attributes)
      comment = Comment.create!(body: "Nice!", community_post: post, user: user)
      expect { post.destroy }.to change(Comment, :count).by(-1)
    end
  end

  describe ".fuzzy_search" do
    let!(:post1) do
      described_class.create!(title: "Ruby on Rails Guide", content: "Learn web development", user: user)
    end
    let!(:post2) do
      described_class.create!(title: "Python Tips", content: "Python programming tricks", user: user)
    end
    let!(:post3) do
      described_class.create!(title: "JavaScript Basics", content: "Intro to JS", user: user)
    end

    it "returns all posts when query is blank" do
      results = described_class.fuzzy_search("")
      expect(results.count).to eq(3)
    end

    it "returns posts matching by title similarity" do
      results = described_class.fuzzy_search("Ruby")
      expect(results).to include(post1)
      expect(results).not_to include(post2, post3)
    end

    it "returns posts matching by content ILIKE" do
      results = described_class.fuzzy_search("Python")
      expect(results).to include(post2)
    end

    it "orders by similarity descending" do
      described_class.create!(title: "Ruby Advanced", content: "More Ruby", user: user)
      results = described_class.fuzzy_search("Ruby")
      expect(results.first.title).to match(/Ruby Advanced/)
    end
  end
end
