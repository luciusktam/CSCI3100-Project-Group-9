require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe "validations" do
    let(:user1) do
      User.create!(
        username: "user1",
        email: "user1@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user2) do
      User.create!(
        username: "user2",
        email: "user2@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end

    it "is valid with two different users" do
      conversation = Conversation.new(user1: user1, user2: user2)
      expect(conversation).to be_valid
    end

    it "is invalid with the same user" do
      conversation = Conversation.new(user1: user1, user2: user1)
      expect(conversation).to be_invalid
      expect(conversation.errors[:base]).to include("Cannot create conversation with yourself")
    end

    it "requires user1_id" do
      conversation = Conversation.new(user2: user2)
      expect(conversation).to be_invalid
      expect(conversation.errors[:user1_id]).to include("can't be blank")
    end

    it "requires user2_id" do
      conversation = Conversation.new(user1: user1)
      expect(conversation).to be_invalid
      expect(conversation.errors[:user2_id]).to include("can't be blank")
    end
  end

  describe "associations" do
    let(:user1) do
      User.create!(
        username: "user1",
        email: "user1@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user2) do
      User.create!(
        username: "user2",
        email: "user2@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }
    
    it "belongs to user1" do
      expect(conversation.user1).to eq(user1)
    end
    
    it "belongs to user2" do
      expect(conversation.user2).to eq(user2)
    end
    
    it "has many messages" do
      message1 = Message.create!(conversation: conversation, user: user1, content: "Hello")
      message2 = Message.create!(conversation: conversation, user: user2, content: "Hi")
      
      expect(conversation.messages).to include(message1, message2)
    end
    
    it "destroys messages when conversation is destroyed" do
      Message.create!(conversation: conversation, user: user1, content: "Hello")
      expect {
        conversation.destroy
      }.to change(Message, :count).by(-1)
    end
  end

  describe "#other_user" do
    let(:user1) do
      User.create!(
        username: "user1",
        email: "user1@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user2) do
      User.create!(
        username: "user2",
        email: "user2@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }

    it "returns user2 when current user is user1" do
      expect(conversation.other_user(user1)).to eq(user2)
    end

    it "returns user1 when current user is user2" do
      expect(conversation.other_user(user2)).to eq(user1)
    end
  end

  describe "#participant?" do
    let(:user1) do
      User.create!(
        username: "user1",
        email: "user1@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user2) do
      User.create!(
        username: "user2",
        email: "user2@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user3) do
      User.create!(
        username: "user3",
        email: "user3@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }

    it "returns true for user1" do
      expect(conversation.participant?(user1)).to be true
    end

    it "returns true for user2" do
      expect(conversation.participant?(user2)).to be true
    end

    it "returns false for non-participant" do
      expect(conversation.participant?(user3)).to be false
    end
  end

  describe "#last_message" do
    let(:user1) do
      User.create!(
        username: "user1",
        email: "user1@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user2) do
      User.create!(
        username: "user2",
        email: "user2@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:conversation) { Conversation.create!(user1: user1, user2: user2) }
    
    it "returns nil when no messages" do
      expect(conversation.last_message).to be_nil
    end

    it "returns the most recent message" do
      message1 = Message.create!(
        conversation: conversation,
        user: user1,
        content: "First",
        created_at: 2.hours.ago
      )
      
      message2 = Message.create!(
        conversation: conversation,
        user: user2,
        content: "Second",
        created_at: 1.hour.ago
      )
      
      expect(conversation.last_message).to eq(message2)
    end
  end

  describe "#unread_count_for" do

    before(:each) do
      # Delete dependent records first (due to foreign key constraints)
      CommunityPost.delete_all
      Comment.delete_all
      Message.delete_all
      Conversation.delete_all
      Listing.delete_all
      User.delete_all
    end

    let(:buyer) do
      User.create!(
        username: "buyer",
        email: "buyer@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:seller) do
      User.create!(
        username: "seller",
        email: "seller@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:conversation) { Conversation.create!(user1: buyer, user2: seller) }
    
    it "counts unread messages from other user" do
      # Create 2 unread messages from seller
      Message.create!(conversation: conversation, user: seller, content: "Message 1", read: false)
      Message.create!(conversation: conversation, user: seller, content: "Message 2", read: false)
      # Create 1 message from buyer (should not be counted)
      Message.create!(conversation: conversation, user: buyer, content: "My message", read: false)
      
      expect(conversation.unread_count_for(buyer)).to eq(2)
    end

    it "returns 0 when no messages from other user" do
      # Only messages from current user
      Message.create!(conversation: conversation, user: buyer, content: "My message", read: false)
      
      expect(conversation.unread_count_for(buyer)).to eq(0)
    end

    it "does not count read messages" do
      # Create 1 unread and 1 read message from seller
      Message.create!(conversation: conversation, user: seller, content: "Unread", read: false)
      Message.create!(conversation: conversation, user: seller, content: "Read", read: true)
      
      expect(conversation.unread_count_for(buyer)).to eq(1)
    end
  end

  describe ".find_or_create_between" do
    let(:user1) do
      User.create!(
        username: "user1",
        email: "user1@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end
    
    let(:user2) do
      User.create!(
        username: "user2",
        email: "user2@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
    end

    it "finds existing conversation" do
      existing = Conversation.create!(user1: user1, user2: user2)
      found = Conversation.find_or_create_between(user1, user2)
      expect(found).to eq(existing)
    end

    it "creates new conversation if doesn't exist" do
      expect {
        Conversation.find_or_create_between(user1, user2)
      }.to change(Conversation, :count).by(1)
    end

    it "creates conversation with user order normalized" do
      conv1 = Conversation.find_or_create_between(user1, user2)
      conv2 = Conversation.find_or_create_between(user2, user1)
      expect(conv1).to eq(conv2)
    end
  end
end