class Listing < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many_attached :photos

  pg_search_scope :search_by_keyword,
                  against: %i[title description location],
                  using: {
                    trigram: {
                      threshold: 0.1
                    }
                  }

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
  validates :condition, presence: true

  validate :photos_count_within_limit
  validate :photos_must_be_attached

  private

  def photos_must_be_attached
    errors.add(:photos, "must be attached") unless photos.attached?
  end

  def photos_count_within_limit
    return unless photos.attached?

    if photos.count > 8
      errors.add(:photos, "maximum 8 photos allowed")
    end
  end
end
