class Employee < ApplicationRecord
  has_secure_password
    belongs_to :hr,
             class_name: "User"
  has_many :leaves,
         foreign_key: :email,
         primary_key: :email,
         dependent: :destroy
end