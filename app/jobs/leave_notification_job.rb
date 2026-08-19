class LeaveNotificationJob < ApplicationJob

  queue_as :default

  def perform(user_id, title, message)

    user = User.find(user_id)

    # Save notification in database
    Notification.create!(
      user_id: user.id,
      title: title,
      message: message,
      notification_type: "leave"
    )

    Rails.logger.info(
      "FCM: Checking tokens for user #{user.id}"
    )

    device_tokens =
      DeviceToken.where(user_id: user.id)

    if device_tokens.empty?

      Rails.logger.warn(
        "No FCM token found for user #{user.id} (#{user.email})"
      )

      return
    end

    Rails.logger.info(
      "FCM: Found #{device_tokens.count} token(s) for user #{user.id}"
    )

    device_tokens.find_each do |device_token|

      begin

        Rails.logger.info(
          "FCM: Sending notification to token #{device_token.id}"
        )

        FirebaseNotificationService.send_notification(
          device_token.token,
          title,
          message
        )

        Rails.logger.info(
          "FCM: Notification sent successfully to token #{device_token.id}"
        )

      rescue => e

        Rails.logger.error(
          "FCM notification failed for user #{user.id}, " \
          "token #{device_token.id}: #{e.message}"
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