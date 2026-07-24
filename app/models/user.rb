class User < ApplicationRecord

  has_secure_password


  belongs_to :company,
             optional: true


  belongs_to :hr,
             class_name: "User",
             optional: true


  has_many :employees,
           class_name: "User",
           foreign_key: "hr_id",
           dependent: :destroy


  has_many :leaves,
           class_name: "Leave",
           foreign_key: :email,
           primary_key: :email,
           dependent: :destroy


  has_many :device_tokens,
           dependent: :destroy


  has_one_attached :profile_image


  enum :role, {
    employee: 0,
    hr: 1
  }


  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "name",
      "email",
      "role",
      "address",
      "salary",
      "company_id",
      "created_at",
      "updated_at",
      "password_digest"
    ]
  end


  def self.ransackable_associations(auth_object = nil)
    [
      "company",
      "hr",
      "employees"
    ]
  end

end