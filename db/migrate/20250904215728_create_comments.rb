class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :text
      t.references :to_do_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
