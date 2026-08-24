class WelcomeNotificationJob < ApplicationJob
  queue_as :default

  def perform(id, type)

    if type == "company"

      company = Company.find(id)

      Notification.create!(
        company_id: company.id,
        title: "Welcome",
        message: "Welcome #{company.name} to WorkSphere Portal",
        notification_type: "welcome"
      )

      tokens = DeviceToken.where(
        company_id: company.id
      ).pluck(:token)

      tokens.each do |token|

        FirebaseNotificationService.send_notification(
          token,
          "Welcome",
          "Welcome #{company.name} to WorkSphere Portal"
        )

      end

    elsif type == "hr" || type == "employee"

      user = User.find(id)

      Notification.create!(
        user_id: user.id,
        title: "Welcome",
        message: "Welcome #{user.name} to WorkSphere Portal",
        notification_type: "welcome"
      )

      device_tokens = DeviceToken.where(
        user_id: user.id
      ).pluck(:token)

      device_tokens.each do |token|

        FirebaseNotificationService.send_notification(
          token,
          "Welcome",
          "Welcome #{user.name} to WorkSphere Portal"
        )

      end

    end

  end
end