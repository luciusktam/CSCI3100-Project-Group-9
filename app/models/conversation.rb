class Conversation < ApplicationRecord
  belongs_to :user1, class_name: "User"
  belongs_to :user2, class_name: "User"
  has_many :messages, dependent: :destroy
  
  validates :user1_id, presence: true
  validates :user2_id, presence: true
  validate :different_users
  
  def other_user(current_user)
    current_user.id == user1_id ? user2 : user1
  end
  
  def participant?(user)
    user1_id == user.id || user2_id == user.id
  end
  
  def last_message
    messages.order(created_at: :desc).first
  end
  
  def unread_count_for(user)
    other = other_user(user)
    messages.where(user: other, read: false).count
  end
  
  def self.find_or_create_between(user1, user2)
    conversation = find_by(user1: user1, user2: user2) || 
                   find_by(user1: user2, user2: user1)
    
    unless conversation
      conversation = create(user1: user1, user2: user2)
    end
    
    conversation
  end
  
  private
  
  def different_users
    if user1_id == user2_id
      errors.add(:base, "Cannot create conversation with yourself")
    end
  end
end