# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
AdminUser.find_or_initialize_by(email: "admin@gmail.com").tap do |admin|
  admin.password = "Admin@123"
  admin.password_confirmation = "Admin@123"
  admin.save!
end

# User.create(
#   name: "Hr",
#   email: "hr@gmail.com",
#   password: "test@123",
#   password_confirmation: "test@123"
# )

# User.find_or_initialize_by(email: "hr@gmail.com").tap do |userr|
#   userr.password = "Test@123"
#   userr.password_confirmation = "Test@123"
#   userr.save!
# end

