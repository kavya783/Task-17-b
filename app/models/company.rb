class Company < ApplicationRecord

  has_secure_password

  has_many :users, dependent: :destroy

  has_many :hrs,
           -> { where(role: :hr) },
           class_name: "User"

  has_many :employees,
           -> { where(role: :employee) },
           class_name: "User"


  def self.ransackable_associations(auth_object = nil)
    [
      "users",
      "hrs",
      "employees"
    ]
  end


  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "name",
      "email",
      "address",
      "password_digest",
      "created_at",
      "updated_at"
    ]
  end

end