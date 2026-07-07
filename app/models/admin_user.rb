class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  enum :role, {
    super_admin: 0,
    admin: 1
  }

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      email
      role
      created_at
      updated_at
    ]
  end
end