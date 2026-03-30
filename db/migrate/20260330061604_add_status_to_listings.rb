class AddStatusToListings < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:listings, :status)
      add_column :listings, :status, :string
    end
  end
end
