require 'rails_helper'

RSpec.describe "Chat", type: :request do

  before(:each) do
    # Delete messages first (due to foreign key constraints)
    Message.delete_all
    # Then delete conversations
    Conversation.delete_all
    # Finally delete users
    User.delete_all
  end

  let!(:buyer) do
    User.create!(
      username: "buyer",
      email: "buyer@link.cuhk.edu.hk",
      password: "password123",
      password_confirmation: "password123",
      email_verified: true,
      verified_at: Time.current
    )
  end
  
  let!(:seller) do
    User.create!(
      username: "seller",
      email: "seller@link.cuhk.edu.hk",
      password: "password123",
      password_confirmation: "password123",
      email_verified: true,
      verified_at: Time.current
    )
  end
  
  let!(:other_user) do
    User.create!(
      username: "other",
      email: "other@link.cuhk.edu.hk",
      password: "password123",
      password_confirmation: "password123",
      email_verified: true,
      verified_at: Time.current
    )
  end
  
  let!(:listing) do
    Listing.create!(
      title: "Test Item",
      description: "Test description",
      price: 100.00,
      category: "Electronics",
      condition: "New",
      location: "CUHK",
      status: "available",
      user: seller,
      photos: [fixture_file_upload(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg")]
    )
  end

  # Helper method to login
  def login_as(user)
    post login_path, params: { email: user.email, password: user.password }
    follow_redirect! if response.redirect?
  end
  
  def logout
    delete logout_path
  end

  before do
    login_as(buyer)
  end

  after do
    logout
  end

  describe "GET /chat" do
    it "returns success" do
      get chat_path
      expect(response).to be_successful
    end

    it "displays empty state when no conversations" do
      Conversation.destroy_all
      get chat_path
      expect(response.body).to include("No conversation selected")
    end

    it "shows conversations when they exist" do
      get chat_path
      expect(response.body).to include(seller.username)
    end
  end

  describe "GET /chat/:user_id" do
    it "creates conversation when clicking on a seller" do
      new_seller = User.create!(
        username: "newseller",
        email: "newseller@link.cuhk.edu.hk",
        password: "password123",
        password_confirmation: "password123",
        email_verified: true,
        verified_at: Time.current
      )
      
      existing_conversation = Conversation.find_by(user1: buyer, user2: new_seller) || Conversation.find_by(user1: new_seller, user2: buyer)
      expect(existing_conversation).to be_nil
      
      expect {
        get chat_with_user_path(new_seller)
      }.to change(Conversation, :count).by(1)
    end

    it "returns success for existing conversation" do
      conversation = Conversation.create!(user1: buyer, user2: seller)
      
      get chat_with_user_path(seller)
      expect(response).to be_successful
    end

    it "displays the chat window with seller name" do
      get chat_with_user_path(seller)
      expect(response.body).to include(seller.username)
    end
  end

  describe "GET /chat/:user_id/messages.json" do
    let(:conversation) { Conversation.create!(user1: buyer, user2: seller) }
    
    it "returns empty array when no messages" do
      get "/chat/#{seller.id}/messages", params: { format: :json }
      
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it "marks messages as read when fetched" do
      message = Message.create!(
        conversation: conversation,
        user: seller,
        content: "Unread message",
        read: false
      )
      
      expect(message.read).to be false
      
      get "/chat/#{seller.id}/messages", params: { format: :json }
      
      message.reload
      expect(message.read).to be true
    end

    it "does not mark own messages as read" do
      message = Message.create!(
        conversation: conversation,
        user: buyer,
        content: "My message",
        read: false
      )
      
      get "/chat/#{seller.id}/messages", params: { format: :json }
      
      message.reload
      expect(message.read).to be false
    end
  end

  describe "POST /chat/:user_id/send_message" do
    let(:conversation) { Conversation.create!(user1: buyer, user2: seller) }
    
    it "creates a new message" do
      expect {
        post "/chat/#{seller.id}/send_message",
             params: { message: { content: "Hello!" } },
             as: :json
      }.to change(Message, :count).by(1)
    end

    it "prevents empty messages" do
      expect {
        post "/chat/#{seller.id}/send_message",
             params: { message: { content: "" } },
             as: :json
      }.not_to change(Message, :count)
    end

    it "prevents messages longer than 1000 characters" do
      long_message = "a" * 1001
      expect {
        post "/chat/#{seller.id}/send_message",
             params: { message: { content: long_message } },
             as: :json
      }.not_to change(Message, :count)
    end

    it "returns error for message too long" do
      long_message = "a" * 1001
      post "/chat/#{seller.id}/send_message",
           params: { message: { content: long_message } },
           as: :json
      
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["success"]).to be false
      expect(json["errors"]).to include("Content is too long (maximum is 1000 characters)")
    end
  end

  describe "Unread messages functionality" do
    it "shows unread badge in conversation list" do
      conversation = Conversation.create!(user1: buyer, user2: seller)
      Message.create!(
        conversation: conversation,
        user: seller,
        content: "Unread message",
        read: false
      )

      get chat_path
      expect(response.body).to include("unread-badge")
    end

    it "does not show unread badge for read messages" do
      conversation = Conversation.create!(user1: buyer, user2: seller)
      Message.create!(
        conversation: conversation,
        user: seller,
        content: "Read message",
        read: true
      )

      get chat_path
      expect(response.body).not_to include("unread-badge")
    end
  end

  describe "GET /chat/unread_counts" do
    it "returns empty counts when no unread messages" do
      get chat_unread_counts_path
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["unread_counts"]).to be_empty
    end

    it "returns unread counts for conversations with unread messages" do
      conversation = Conversation.create!(user1: buyer, user2: seller)
      Message.create!(
        conversation: conversation,
        user: seller,
        content: "Unread message 1",
        read: false
      )
      Message.create!(
        conversation: conversation,
        user: seller,
        content: "Unread message 2",
        read: false
      )

      get chat_unread_counts_path
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["unread_counts"][seller.id.to_s]).to eq(2)
    end

    it "does not count own messages as unread" do
      conversation = Conversation.create!(user1: buyer, user2: seller)
      Message.create!(
        conversation: conversation,
        user: buyer,
        content: "My message",
        read: false
      )

      get chat_unread_counts_path
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["unread_counts"][seller.id.to_s]).to be_nil
    end
  end

  describe "POST /chat/update_unread_count" do
    let(:conversation) { Conversation.create!(user1: buyer, user2: seller) }

    it "marks messages as read for a conversation" do
      message = Message.create!(
        conversation: conversation,
        user: seller,
        content: "Unread message",
        read: false
      )

      expect(message.read).to be false

      post chat_update_unread_count_path, params: { user_id: seller.id }
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["success"]).to be true

      message.reload
      expect(message.read).to be true
    end

    it "returns zero when no unread messages" do
      post chat_update_unread_count_path, params: { user_id: seller.id }
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["updated_count"]).to eq(0)
    end
  end
end
