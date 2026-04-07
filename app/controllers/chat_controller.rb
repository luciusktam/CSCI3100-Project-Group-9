class ChatController < ApplicationController
  before_action :authenticate_user_chat!
  
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

    # NO mark as read here anymore

    @conversations = Conversation.where("user1_id = ? OR user2_id = ?", current_user.id, current_user.id)
                                .order(updated_at: :desc)

    @chat_users = @conversations.map { |conv| conv.other_user(current_user) }.uniq

    # Pre-compute unread counts to avoid N+1 in view
    @unread_counts = {}
    @conversations.each do |conv|
      count = conv.unread_count_for(current_user)
      @unread_counts[conv.other_user(current_user).id] = count if count > 0
    end

    @messages = @conversation.messages.order(created_at: :asc)

    render :index
  end
  
  def messages
    @other_user = User.find(params[:user_id])
    @conversation = Conversation.find_or_create_between(current_user, @other_user)

    # Mark as read ONLY if there are unread messages + use lock
    @conversation.with_lock do
      unread = @conversation.messages.where(user: @other_user, read: false)
      if unread.exists?
        unread.update_all(read: true)
      end
    end

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

  def update_unread_count
    other_user = User.find(params[:user_id])
    conversation = Conversation.find_or_create_between(current_user, other_user)
    
    # Use a transaction with row-level locking to prevent race conditions
    conversation.with_lock do
      # Only update if there are actually unread messages
      unread_messages = conversation.messages.where(user: other_user, read: false)
      
      if unread_messages.exists?
        updated_count = unread_messages.update_all(read: true)
        render json: { success: true, updated_count: updated_count }
      else
        render json: { success: true, updated_count: 0, message: "No unread messages" }
      end
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  def unread_counts
    # Cache the result for 2 seconds to prevent multiple rapid requests
    cache_key = "unread_counts_#{current_user.id}_#{Time.now.to_i / 2}"
    
    unread_counts = Rails.cache.fetch(cache_key, expires_in: 2.seconds) do
      counts = {}
      conversations = Conversation.where("user1_id = ? OR user2_id = ?", current_user.id, current_user.id)
      
      conversations.each do |conversation|
        unread_count = conversation.unread_count_for(current_user)
        if unread_count > 0
          other_user = conversation.other_user(current_user)
          counts[other_user.id.to_s] = unread_count
        end
      end
      
      counts
    end
    
    render json: { unread_counts: unread_counts }
  end

  private
  
end