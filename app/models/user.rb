class User < ApplicationRecord
  has_secure_password
     has_many :leaves, class_name: "Leave", foreign_key: "user_id"
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
      "created_at",
      "updated_at",
      "password_digest"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end