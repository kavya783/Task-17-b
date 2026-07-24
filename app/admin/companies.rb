ActiveAdmin.register Company do

  config.filters = false

  permit_params :name, :email, :address, :password, :password_confirmation


  index do
    selectable_column
    id_column

    column :name
    column :email
    column :address

    actions
  end


  form do |f|

    f.inputs do
      f.input :name
      f.input :email
      f.input :address
      f.input :password
      f.input :password_confirmation
    end

    f.actions

  end

end