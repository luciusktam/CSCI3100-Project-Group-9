class User < ApplicationRecord
  has_secure_password
  has_many :listings, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, default: :user

  VALID_CUHK_EMAIL_REGEX = /\A[^@\s]+@link\.cuhk\.edu\.hk\z/i

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_CUHK_EMAIL_REGEX }
  validates :username, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
