class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.decimal :price
      t.string :condition
      t.text :description
      t.string :location
      t.string :category

      t.timestamps
    end
  end
end
