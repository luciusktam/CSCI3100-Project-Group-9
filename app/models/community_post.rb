class CommunityPost < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  validates :content, presence: true
  validates :title, presence: true
  validates :title, length: { maximum: 100 }, allow_blank: true

  scope :fuzzy_search, ->(query) {
    return all if query.blank?

    q = sanitize_sql_like(query.strip)

    where(
      <<~SQL,
        similarity(title, :q) > 0.15
        OR similarity(content, :q) > 0.15
        OR title ILIKE :like
        OR content ILIKE :like
      SQL
      q: q,
      like: "%#{q}%"
    ).order(
      Arel.sql(
        sanitize_sql_array([
          "GREATEST(similarity(title, ?), similarity(content, ?)) DESC, created_at DESC",
          q, q
        ])
      )
    )
  }
end
