require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:user) do
    User.create!(
      username: "user",
      email: "user@link.cuhk.edu.hk",
      password: "password123",
      password_confirmation: "password123",
      email_verified: true,
      verified_at: Time.current
    )
  end
  
  let(:other_user) do
    User.create!(
      username: "other",
      email: "other@link.cuhk.edu.hk",
      password: "password123",
      password_confirmation: "password123",
      email_verified: true,
      verified_at: Time.current
    )
  end
  
  let(:conversation) { Conversation.create!(user1: user, user2: other_user) }

  describe "validations" do
    it "is valid with content" do
      message = Message.new(conversation: conversation, user: user, content: "Hello")
      expect(message).to be_valid
    end

    it "is invalid without content" do
      message = Message.new(conversation: conversation, user: user, content: nil)
      expect(message).to be_invalid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it "is invalid with blank content" do
      message = Message.new(conversation: conversation, user: user, content: "   ")
      expect(message).to be_invalid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it "is invalid with content longer than 1000 characters" do
      message = Message.new(
        conversation: conversation,
        user: user,
        content: "a" * 1001
      )
      expect(message).to be_invalid
      expect(message.errors[:content]).to include("is too long (maximum is 1000 characters)")
    end

    it "is valid with exactly 1000 characters" do
      message = Message.new(
        conversation: conversation,
        user: user,
        content: "a" * 1000
      )
      expect(message).to be_valid
    end
  end

  describe "associations" do
    let(:message) { Message.new(conversation: conversation, user: user, content: "Hello") }
    
    it "belongs to conversation" do
      expect(message.conversation).to eq(conversation)
    end
    
    it "belongs to user" do
      expect(message.user).to eq(user)
    end
  end

  describe "#read" do
    it "defaults to false when created" do
      message = Message.create!(
        conversation: conversation,
        user: user,
        content: "Test message"
      )
      message.save!
      expect(message.read).to eq(false)
    end

    it "can be marked as read" do
      message = Message.create!(
        conversation: conversation,
        user: other_user,
        content: "Test message",
        read: false
      )
      expect(message.read).to be false
      
      message.update(read: true)
      expect(message.reload.read).to be true
    end

    it "persists the read status" do
      message = Message.create!(
        conversation: conversation,
        user: other_user,
        content: "Test message",
        read: true
      )
      expect(message.read).to be true
      
      message.update(read: false)
      expect(message.reload.read).to be false
    end
  end

  describe "callbacks" do
    it "updates conversation timestamp when message is created" do
      conversation = Conversation.create!(user1: user, user2: other_user)
      old_timestamp = conversation.updated_at
      
      sleep(1)
      Message.create!(
        conversation: conversation,
        user: user,
        content: "Test"
      )
      
      expect(conversation.reload.updated_at).to be > old_timestamp
    end
  end
end