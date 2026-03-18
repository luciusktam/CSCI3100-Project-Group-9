class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :title, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :description
      t.string :location, null: false
      t.string :category
      t.references :user, foreign_key: true
      t.timestamps
    end
    
    add_index :listings, :created_at
  end
end
