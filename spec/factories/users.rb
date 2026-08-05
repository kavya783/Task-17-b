FactoryBot.define do
  factory :user do
    name { "Employee" }
    sequence(:email) { |n| "user#{n}@test.com" }
    password { "123456" }
    role { "employee" }

    factory :hr_user do
      role { "hr" }
    end
  end
end