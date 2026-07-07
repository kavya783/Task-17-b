class AddProfileImageToLeaves < ActiveRecord::Migration[8.1]
  def change
    add_column :leaves, :profileImage, :string
  end
end
