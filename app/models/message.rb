class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 1000 }
  
  after_initialize :set_defaults, if: :new_record?
  after_create_commit :update_conversation_timestamp
  
  private
  
  def set_defaults
    self.read = false if self.read.nil?
  end

  def update_conversation_timestamp
    conversation.update(updated_at: Time.current)
  end
end