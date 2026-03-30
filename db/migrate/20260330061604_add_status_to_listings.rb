class AddStatusToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :status, :string
  end
end
