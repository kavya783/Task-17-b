class AddHrIdAndCompanyIdToLeaves < ActiveRecord::Migration[8.1]
  def change
    add_column :leaves, :hr_id, :integer
    add_column :leaves, :company_id, :integer
  end
end
