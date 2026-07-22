class AddHrIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :hr_id, :integer
  end
end
