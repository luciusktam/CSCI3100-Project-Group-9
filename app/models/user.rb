class User < ApplicationRecord
  PASSWORD_RESET_EXPIRY = 30.minutes

  has_one_attached :avatar
  has_many :listings, dependent: :destroy

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

  def generate_password_reset_token!
    # Generate a random token and store its digest
    token = SecureRandom.hex(32)
    digest = BCrypt::Password.create(token)
    update!(reset_password_token_digest: digest)
    token # Return the plaintext token to send in email
  end

  def reset_password_token_matches?(token)
    return false if reset_password_token_digest.blank?
    
    BCrypt::Password.new(reset_password_token_digest) == token
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def clear_password_reset_token!
    update!(reset_password_token_digest: nil)
  end

  def password_reset_token_expired?
    reset_password_token_digest.blank? || reset_password_sent_at.blank? || reset_password_sent_at < PASSWORD_RESET_EXPIRY.ago
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
