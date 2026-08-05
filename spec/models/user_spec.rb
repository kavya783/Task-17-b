require "rails_helper"

RSpec.describe User, type: :model do

  describe "ransack configuration" do

    it "returns ransackable attributes" do

      attributes = User.ransackable_attributes

      expect(attributes).to include(
        "email",
        "name",
        "role",
        "company_id"
      )

    end


    it "returns ransackable associations" do

      associations = User.ransackable_associations

      expect(associations).to include(
        "company"
      )

    end

  end


  describe "associations" do

    it "has company association" do

      association = User.reflect_on_association(:company)

      expect(association.macro).to eq(:belongs_to)

    end


    it "has profile image attachment" do

      expect(
        User.new.profile_image
      ).to be_present.or be_nil

    end

  end

end