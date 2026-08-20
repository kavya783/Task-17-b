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

    device_token = DeviceToken.find_by(user_id: user.id)

    if device_token.present?
      FirebaseNotificationService.send_notification(
        device_token.token,
        title,
        message
      )
    end
  end
end