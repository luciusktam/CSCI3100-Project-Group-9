class AddVerificationSentAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :verification_sent_at, :datetime
    add_index :users, :verification_sent_at
  end
end
