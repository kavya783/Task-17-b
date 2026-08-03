class AddCompanyIdToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :company_id, :integer
  end
end
