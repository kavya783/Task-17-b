class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :address, :string
    add_column :users, :salary, :string
  end
end
