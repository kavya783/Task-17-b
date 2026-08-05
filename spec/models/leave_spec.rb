require "rails_helper"

RSpec.describe Leave, type: :model do

  describe "validations" do

    it "is valid with required fields" do

      leave = build(:leave)

      expect(leave).to be_valid

    end


    it "requires employeename" do

      leave = build(:leave, employeename: nil)

      expect(leave).not_to be_valid

    end


    it "requires email" do

      leave = build(:leave, email: nil)

      expect(leave).not_to be_valid

    end

  end


  describe "ransack configuration" do

    it "returns ransackable associations" do

      associations = Leave.ransackable_associations

      expect(associations).to include(
        "user"
      )

    end


    it "returns ransackable attributes" do

      attributes = Leave.ransackable_attributes

      expect(attributes).to include(
        "status",
        "reason",
        "from_date",
        "to_date"
      )

    end

  end


  describe "associations" do

    it "belongs to user" do

      association = Leave.reflect_on_association(:user)

      expect(association.macro).to eq(:belongs_to)

    end

  end

end