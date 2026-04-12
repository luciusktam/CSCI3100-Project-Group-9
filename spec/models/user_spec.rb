require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) do
    described_class.new(
      email: "student@link.cuhk.edu.hk",
      username: "student",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  it "is valid with a CUHK email and password" do
    expect(user).to be_valid
  end

  it "normalizes email before validation" do
    user.email = "  STUDENT@LINK.CUHK.EDU.HK  "

    user.valid?

    expect(user.email).to eq("student@link.cuhk.edu.hk")
  end

  it "rejects non-CUHK emails" do
    user.email = "student@gmail.com"

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  it "requires a username" do
    user.username = nil

    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("can't be blank")
  end

  it "requires a password with minimum length" do
    user.password = "short"
    user.password_confirmation = "short"

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
  end

  it "defaults to the user role" do
    expect(user.role).to eq("user")
  end

  it "allows the admin role" do
    user.role = :admin

    expect(user.admin?).to be(true)
  end

  it "enforces case-insensitive email uniqueness" do
    described_class.create!(
      email: "student@link.cuhk.edu.hk",
      username: "student1",
      password: "Password123",
      password_confirmation: "Password123"
    )

    duplicate = described_class.new(
      email: "STUDENT@link.cuhk.edu.hk",
      username: "student2",
      password: "Password123",
      password_confirmation: "Password123"
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include("has already been taken")
  end

  describe "#banned?" do
    it "returns false when banned_until is nil" do
      user.banned_until = nil
      expect(user).not_to be_banned
    end

    it "returns false when banned_until is in the past" do
      user.banned_until = 1.hour.ago
      expect(user).not_to be_banned
    end

    it "returns true when banned_until is in the future" do
      user.banned_until = 1.hour.from_now
      expect(user).to be_banned
    end
  end

  describe "#suspended?" do
    it "delegates to #banned?" do
      user.banned_until = 1.hour.from_now
      expect(user).to be_suspended
    end
  end

  describe "#banned_until" do
    it "returns the raw attribute value" do
      freeze_time = Time.current
      user.banned_until = freeze_time
      expect(user.banned_until).to eq(freeze_time)
    end
  end

  describe "#generate_password_reset_token!" do
    it "sets reset_password_token_digest" do
      expect { user.generate_password_reset_token! }.to change { user.reset_password_token_digest }.from(nil)
    end

    it "returns a 64-character hex string" do
      token = user.generate_password_reset_token!
      expect(token.length).to eq(64)
      expect(token).to match(/\A[0-9a-f]{64}\z/)
    end
  end

  describe "#reset_password_token_matches?" do
    it "returns true for the correct token" do
      token = user.generate_password_reset_token!
      expect(user.reset_password_token_matches?(token)).to be true
    end

    it "returns false for a wrong token" do
      user.generate_password_reset_token!
      expect(user.reset_password_token_matches?("wrong_token")).to be false
    end

    it "returns false when no token was generated" do
      user.reset_password_token_digest = nil
      expect(user.reset_password_token_matches?("any")).to be false
    end

    it "returns false for a malformed digest" do
      user.reset_password_token_digest = "not_a_bcrypt_digest"
      expect(user.reset_password_token_matches?("any")).to be false
    end
  end

  describe "#clear_password_reset_token!" do
    it "clears the digest" do
      user.generate_password_reset_token!
      user.clear_password_reset_token!
      expect(user.reset_password_token_digest).to be_nil
    end
  end

  describe "#password_reset_token_expired?" do
    it "returns true when no token was generated" do
      user.reset_password_token_digest = nil
      user.reset_password_sent_at = nil
      expect(user.password_reset_token_expired?).to be true
    end

    it "returns true when token is older than 30 minutes" do
      user.reset_password_sent_at = 31.minutes.ago
      user.reset_password_token_digest = "something"
      expect(user.password_reset_token_expired?).to be true
    end

    it "returns false when token is within 30 minutes" do
      user.reset_password_sent_at = 10.minutes.ago
      user.reset_password_token_digest = "something"
      expect(user.password_reset_token_expired?).to be false
    end
  end

  describe "#conversations" do
    let!(:other_user) do
      described_class.create!(
        email: "other@link.cuhk.edu.hk",
        username: "otheruser",
        password: "Password123",
        password_confirmation: "Password123"
      )
    end

    before { user.save! }

    it "returns conversations where the user is user1 or user2" do
      c1 = Conversation.create!(user1: user, user2: other_user)
      expect(user.conversations).to include(c1)
    end

    it "orders by updated_at desc" do
      c1 = Conversation.create!(user1: user, user2: other_user)
      sleep 0.01
      c2 = Conversation.create!(user1: other_user, user2: user)
      expect(user.conversations.first).to eq(c2)
    end
  end
end