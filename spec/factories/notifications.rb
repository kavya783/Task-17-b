FactoryBot.define do

  factory :notification do

    title { "Test Notification" }

    message { "Test Message" }

    notification_type { "leave" }

    read { false }

  end

end