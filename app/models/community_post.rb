class CommunityPost < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  validates :content, presence: true
  validates :title, presence: true
  validates :title, length: { maximum: 100 }, allow_blank: true
end
