class AddHrIdToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :hr_id, :integer
  end
end
