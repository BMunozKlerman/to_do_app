class CreateToDoItems < ActiveRecord::Migration[8.0]
  def change
    create_table :to_do_items do |t|
      t.string :token, null: false
      t.string :name, null: false
      t.string :status, default: 'pending'
      t.date :due_date
      t.text :description
      t.references :assigned_to, null: false, foreign_key: { to_table: :users }
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.jsonb :followers, default: []

      t.timestamps
    end

    add_index :to_do_items, :token, unique: true
    add_index :to_do_items, :status
    add_index :to_do_items, :due_date
    add_index :to_do_items, :followers, using: :gin
  end
end
