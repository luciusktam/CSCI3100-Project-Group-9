class User < ApplicationRecord
  PASSWORD_RESET_EXPIRY = 30.minutes

  has_many :community_posts, dependent: :destroy

  has_one_attached :avatar
  has_many :listings, dependent: :destroy

  has_secure_password

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

  has_many :conversations_as_user1, class_name: "Conversation", foreign_key: "user1_id", dependent: :destroy
  has_many :conversations_as_user2, class_name: "Conversation", foreign_key: "user2_id", dependent: :destroy
  
  def conversations
    Conversation.where("user1_id = ? OR user2_id = ?", id, id).order(updated_at: :desc)
  end
  
  def banned_until
    self[:banned_until]
  end

  def banned?
    banned_until.present? && banned_until > Time.current
  end

  def suspended?
    banned?
  end

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
