FactoryBot.define do
  factory :employee do
    password { "123456" }
    association :hr, factory: :hr_user
  end
end