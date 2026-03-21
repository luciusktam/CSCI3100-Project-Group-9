class AddResetPasswordTokenDigestToUsers < ActiveRecord::Migration[8.1]
  def change
    # Add new digest column for secure token storage
    add_column :users, :reset_password_token_digest, :string
    add_index :users, :reset_password_token_digest, unique: true

    # Remove old plaintext token column (reset_password_sent_at already exists from create_users)
    if column_exists?(:users, :reset_password_token)
      remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)
      remove_column :users, :reset_password_token, :string
    end
  end
end
