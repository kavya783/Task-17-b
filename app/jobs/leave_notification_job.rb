class LeaveNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, message)

    user = User.find(user_id)

    Notification.create!(
      user_id: user.id,
      title: title,
      message: message,
      notification_type: "leave"
    )

    device_tokens = DeviceToken.where(user_id: user.id)

    device_tokens.find_each do |device_token|

      begin

        FirebaseNotificationService.send_notification(
          device_token.token,
          title,
          message
        )

      rescue => e

        Rails.logger.error(
          "FCM notification failed for user #{user.id}, token #{device_token.id}: #{e.message}"
        )

        if e.message.include?("UNREGISTERED")
          device_token.destroy

          Rails.logger.info(
            "Deleted invalid FCM token #{device_token.id}"
          )
        end

      end

    end

  end
end