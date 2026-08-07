class AddPolymorphicToLeaves < ActiveRecord::Migration[8.1]
  def change
    add_reference :leaves, :leaveable, polymorphic: true

    remove_column :leaves, :user_id, :integer
    remove_column :leaves, :email, :string
  end
end