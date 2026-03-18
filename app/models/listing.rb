class Listing < ApplicationRecord
  belongs_to :user, optional: true
  
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :location, presence: true
end
