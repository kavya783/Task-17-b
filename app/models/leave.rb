class Leave < ApplicationRecord
  validates :leaveType, :from_date, :to_date, :reason, presence: true

  attribute :status, :string, default: "pending"

  belongs_to :leaveable, polymorphic: true

  # Lambda / Scopes
  scope :pending, -> {
    where(status: "pending")
  }

  scope :approved, -> {
    where(status: "approved")
  }

  scope :rejected, -> {
    where(status: "rejected")
  }

  scope :recent, -> {
    order(created_at: :desc)
  }

  def self.ransackable_associations(auth_object = nil)
    ["leaveable"]
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "leaveable_id",
      "leaveable_type",
      "leaveType",
      "from_date",
      "to_date",  
      "reason",
      "status",
      "created_at",
      "updated_at"
    ]
  end
end