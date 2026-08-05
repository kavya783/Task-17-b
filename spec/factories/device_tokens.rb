FactoryBot.define do

  factory :device_token do

    token { "test_firebase_token_123" }

    association :user

  end

end