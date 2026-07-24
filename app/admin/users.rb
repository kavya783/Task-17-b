ActiveAdmin.register User do
  permit_params :name, :email, :password, :password_confirmation, :role, :company_id, :profile_image

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

  show do
    attributes_table do
        row "Image" do |user|
        if user.profile_image.attached?
          image_tag url_for(user.profile_image), width: 100, height: 100
        else
          "No image"
        end
      end
      row :id
      row :name
      row :email
      row :role
      row :address

     unless user.role == "hr"
    row :salary

      row "FCM Token" do |user|
    user.device_tokens.first&.token || "No Token"
     end
   end
 

    

      row :created_at
      row :updated_at
    end
  end
end