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
      render json: { success: true, message: render_message(@message) }
    else
      render json: { success: false, errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def render_message(message)
    ApplicationController.render(partial: "chat/message", locals: { message: message, current_user: current_user })
  end
end