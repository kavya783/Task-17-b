require "rails_helper"

RSpec.describe Employee, type: :model do
  it "belongs to hr" do
    association = Employee.reflect_on_association(:hr)

    expect(association.macro).to eq(:belongs_to)
    expect(association.class_name).to eq("User")
  end

  it "has many leaves" do
    association = Employee.reflect_on_association(:leaves)

    expect(association.macro).to eq(:has_many)
  end

  it "authenticates with password" do
    employee = build(:employee)

    expect(employee.authenticate("123456")).to eq(employee)
  end
end