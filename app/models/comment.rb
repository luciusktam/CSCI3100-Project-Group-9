class Comment < ApplicationRecord
  belongs_to :community_post
  belongs_to :user

  validates :body, presence: true
end
