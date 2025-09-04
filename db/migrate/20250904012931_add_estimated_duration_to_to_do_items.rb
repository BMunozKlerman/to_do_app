class AddEstimatedDurationToToDoItems < ActiveRecord::Migration[8.0]
  def change
    add_column :to_do_items, :estimated_duration, :string
  end
end
