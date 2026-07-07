class CreateLeaves < ActiveRecord::Migration[8.1]
  def change
    create_table :leaves do |t|
      t.timestamps
    end
  end
end
