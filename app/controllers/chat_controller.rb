class ChatController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Get all conversations for sidebar
    @conversations = Conversation.where("user1_id = ? OR user2_id = ?", 
                                        current_user.id, 
                                        current_user.id)
                                .order(updated_at: :desc)
    
    # Get users from conversations
    @chat_users = @conversations.map { |conv| conv.other_user(current_user) }.uniq
    
    # If there's a user_id parameter, load that conversation
    if params[:user_id]
      @other_user = User.find(params[:user_id])
      @conversation = Conversation.find_or_create_between(current_user, @other_user)
      @messages = @conversation.messages.order(created_at: :asc)
    end
  end
  
  def show
  @other_user = User.find(params[:user_id])
  @conversation = Conversation.find_or_create_between(current_user, @other_user)
  
  # Mark messages as read
  @conversation.messages.where(user: @other_user, read: false).update_all(read: true)
  
  # Get all conversations for sidebar
  @conversations = Conversation.where("user1_id = ? OR user2_id = ?", 
                                      current_user.id, 
                                      current_user.id)
                               .order(updated_at: :desc)
  
  # Get users from conversations
  @chat_users = @conversations.map { |conv| conv.other_user(current_user) }.uniq
  
  # Load messages for this conversation
  @messages = @conversation.messages.order(created_at: :asc)
  
  render :index
end
  
  def messages
    @other_user = User.find(params[:user_id])
    @conversation = Conversation.find_or_create_between(current_user, @other_user)
    @conversation.messages.where(user: @other_user, read: false).update_all(read: true)
    @messages = @conversation.messages.order(created_at: :asc)
    
    render json: @messages.map { |m| 
      {
        id: m.id,
        content: m.content,
        is_current_user: m.user == current_user,
        time_ago: ActionController::Base.helpers.time_ago_in_words(m.created_at)
      }
    }
  end
  
  def send_message
    @other_user = User.find(params[:user_id])
    @conversation = Conversation.find_or_create_between(current_user, @other_user)
    @message = @conversation.messages.build(
      user: current_user,
      content: params[:message][:content]
    )
    
    if @message.save
      render json: { success: true }
    else
      render json: { success: false, errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def unread_counts
    unread_counts = {}
    
    # Get all conversations the current user is part of
    conversations = Conversation.where("user1_id = ? OR user2_id = ?", 
                                       current_user.id, 
                                       current_user.id)
    
    conversations.each do |conversation|
      unread_count = conversation.unread_count_for(current_user)
      if unread_count > 0
        other_user = conversation.other_user(current_user)
        unread_counts[other_user.id.to_s] = unread_count
      end
    end
    
    render json: { unread_counts: unread_counts }
  end

  def update_unread_count
    other_user = User.find(params[:user_id])
    conversation = Conversation.find_or_create_between(current_user, other_user)
    
    # Mark all messages from the other user as read
    updated_count = conversation.messages.where(user: other_user, read: false).update_all(read: true)
    
    render json: { success: true, updated_count: updated_count }
  end

  private
  
end