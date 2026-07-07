class AddFieldsToLeaves < ActiveRecord::Migration[8.1]
  def change
    add_column :leaves, :employeename, :string
    add_column :leaves, :email, :string
    add_column :leaves, :leaveType, :string
    add_column :leaves, :fromDate, :date
    add_column :leaves, :toDate, :date
    add_column :leaves, :reason, :text
    add_column :leaves, :status, :string
  end
end
