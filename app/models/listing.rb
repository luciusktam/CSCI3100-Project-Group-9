class Listing < ApplicationRecord
  has_many_attached :photos
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
