ActiveAdmin.register User do
  permit_params :name, :email, :password, :password_confirmation, :role, :profile_image

  config.filters = false

  index do
    selectable_column
    id_column
    column :email
    column :role

    column "Image" do |user|
      if user.profile_image.attached?
        image_tag url_for(user.profile_image), width: 50, height: 50
      else
        "No image"
      end
    end

    column :created_at
    actions
  end
end