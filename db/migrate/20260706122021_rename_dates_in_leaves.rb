class RenameDatesInLeaves < ActiveRecord::Migration[8.1]
  def change
    rename_column :leaves, :fromDate, :from_date
rename_column :leaves, :toDate, :to_date
  end
end
