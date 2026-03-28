class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :read, null: false, default: false
      t.timestamps
    end
    
    add_index :messages, [:conversation_id, :created_at]
  end
end