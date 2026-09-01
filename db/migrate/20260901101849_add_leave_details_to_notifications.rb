class AddLeaveDetailsToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :notifications, :leave, foreign_key: true
    add_column :notifications, :action, :string
    add_column :notifications, :applied_by, :string
  end
end