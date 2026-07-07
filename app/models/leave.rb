class Leave < ApplicationRecord

  validates :employeename, presence: true
  validates :email, presence: true
  validates :leaveType, presence: true

  validates :from_date, presence: true
  validates :to_date, presence: true
  validates :reason, presence: true

  attribute :status, :string, default: "pending"

  belongs_to :user, optional: true

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "from_date", "to_date", "reason", "status", "created_at", "updated_at"]
  end
end