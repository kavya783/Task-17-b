require "rails_helper"

RSpec.describe Company, type: :model do

  describe "associations" do

    it "has users association" do
      association = Company.reflect_on_association(:users)

      expect(association.macro)
        .to eq(:has_many)

    end


    it "has hrs association" do

      association = Company.reflect_on_association(:hrs)

      expect(association.macro)
        .to eq(:has_many)

    end


    it "has employees association" do

      association = Company.reflect_on_association(:employees)

      expect(association.macro)
        .to eq(:has_many)

    end

  end

 describe "association scopes" do
  it "returns only HR users" do
    company = create(:company)

    hr = create(:user, company: company, role: :hr)
    employee = create(:user, company: company, role: :employee)

    expect(company.hrs).to contain_exactly(hr)
  end

  it "returns only employee users" do
    company = create(:company)

    hr = create(:user, company: company, role: :hr)
    employee = create(:user, company: company, role: :employee)

    expect(company.employees).to contain_exactly(employee)
  end
end
describe "ransack methods" do


    it "returns ransackable associations" do

      result = Company.ransackable_associations

      expect(result)
        .to include(
          "users",
          "hrs",
          "employees"
        )

    end



   it "returns all ransackable attributes" do

            result = Company.ransackable_attributes

            expect(result).to eq(
                [
                "id",
                "name",
                "email",
                "address",
                "password_digest",
                "created_at",
                "updated_at"
                ]
            )

    end


  end
 describe "password authentication" do

  it "authenticates with password" do

    company = Company.new(
      name: "Test Company",
      email: "test@test.com",
      password: "password"
    )

    expect(
      company.authenticate("password")
    ).to eq(company)

  end

end

end