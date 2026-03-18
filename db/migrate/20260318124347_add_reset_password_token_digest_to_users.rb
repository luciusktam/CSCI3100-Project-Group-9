class AddResetPasswordTokenDigestToUsers < ActiveRecord::Migration[8.1]
  def change
    # Add new digest column for secure token storage
    add_column :users, :reset_password_token_digest, :string
    add_index :users, :reset_password_token_digest, unique: true

    # Add timestamp for tracking when reset token was issued
    add_column :users, :reset_password_sent_at, :datetime

    # Remove old plaintext token column
    if column_exists?(:users, :reset_password_token)
      remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)
      remove_column :users, :reset_password_token, :string
    end
  end
end
