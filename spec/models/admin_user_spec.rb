require "rails_helper"

RSpec.describe AdminUser, type: :model do

  describe "ransack configuration" do

    it "returns ransackable attributes" do

      attributes = AdminUser.ransackable_attributes

      expect(attributes).to include(
        "id",
        "email",
        "role",
        "created_at",
        "updated_at"
      )

    end

  end


  describe "enum role" do

    it "has super_admin role" do

      expect(AdminUser.roles).to include(
        "super_admin"
      )

    end


    it "has admin role" do

      expect(AdminUser.roles).to include(
        "admin" 
      )

    end

  end

end