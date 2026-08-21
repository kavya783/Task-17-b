class LeaveNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, message)
    Rails.logger.info "🔥🔥 LEAVE NOTIFICATION JOB STARTED"
    Rails.logger.info "USER ID: #{user_id}"
    Rails.logger.info "TITLE: #{title}"
    Rails.logger.info "MESSAGE: #{message}"

    user = User.find(user_id)

    Rails.logger.info " USER FOUND: #{user.id}"
    Rails.logger.info " USER EMAIL: #{user.email}"
    Rails.logger.info " USER ROLE: #{user.role}"

    notification = Notification.create!(
      user_id: user.id,
      title: title,
      message: message,
      notification_type: "leave"
    )

    Rails.logger.info " DB NOTIFICATION CREATED: #{notification.id}"

    device_token = DeviceToken.find_by(user_id: user.id)

    if device_token.present?
      Rails.logger.info " DEVICE TOKEN FOUND"
      Rails.logger.info "TOKEN ID: #{device_token.id}"

      FirebaseNotificationService.send_notification(
        device_token.token,
        title,
        message
      )

      Rails.logger.info " FIREBASE SEND METHOD CALLED"
    else
      Rails.logger.error "NO DEVICE TOKEN FOR USER #{user.id}"
    end
  end
end