class LeaveNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, message)

    user = User.find_by(id: user_id)

    unless user
      Rails.logger.error(
        "LeaveNotificationJob: User #{user_id} not found"
      )
      return
    end

    # Save notification in database
    Notification.create!(
      user_id: user.id,
      title: title,
      message: message,
      notification_type: "leave"
    )

    # Get ALL FCM tokens for this user
    device_tokens = DeviceToken.where(user_id: user.id)

    if device_tokens.empty?
      Rails.logger.warn(
        "No FCM token found for user #{user.id} (#{user.email})"
      )
      return
    end

    device_tokens.find_each do |device_token|

      begin

        FirebaseNotificationService.send_notification(
          device_token.token,
          title,
          message
        )

        Rails.logger.info(
          "FCM notification sent to user #{user.id}, token #{device_token.id}"
        )

      rescue => e

        Rails.logger.error(
          "FCM notification failed for user #{user.id}, " \
          "token #{device_token.id}: #{e.message}"
        )

        # Remove invalid Firebase token
        if e.message.include?("UNREGISTERED") ||
           e.message.include?("registration-token-not-registered")

          device_token.destroy!

          Rails.logger.info(
            "Deleted invalid FCM token #{device_token.id}"
          )
        end

      end

    end

  rescue => e

    Rails.logger.error(
      "LeaveNotificationJob failed: #{e.class} - #{e.message}"
    )

    raise e
  end
end