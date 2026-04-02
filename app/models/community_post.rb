class CommunityPost < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :title, length: { maximum: 100 }, allow_blank: true
end
