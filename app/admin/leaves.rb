ActiveAdmin.register Leave do

  permit_params :from_date, :to_date, :reason, :status

  filter :from_date
  filter :to_date
  filter :status

  index do
    selectable_column
    id_column

    column "From Date" do |leave|
      leave.from_date
    end

    column "To Date" do |leave|
      leave.to_date
    end

    column :reason
    column :status

    actions
  end

  form do |f|
    f.inputs "Leave Details" do
      f.input :from_date, as: :datepicker
      f.input :to_date, as: :datepicker
      f.input :reason
      f.input :status, as: :select, collection: ["pending", "approved", "rejected"]
    end
    f.actions
  end
end