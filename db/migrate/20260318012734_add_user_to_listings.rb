class AddUserToListings < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:listings, :user_id)
      add_reference :listings, :user, null: false, foreign_key: true
    end
  end
end