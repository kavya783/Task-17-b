class Employee < ApplicationRecord
  has_secure_password

  belongs_to :hr, class_name: "User"

  has_many :leaves,
           as: :leaveable,
           dependent: :destroy
end