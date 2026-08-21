class LeaveNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, message)

    Rails.logger.info " LEAVE NOTIFICATION JOB STARTED"
    Rails.logger.info "USER ID: #{user_id}"
    Rails.logger.info "TITLE: #{title}"
    Rails.logger.info "MESSAGE: #{message}"

    user = User.find_by(id: user_id)

    unless user
      Rails.logger.error "USER NOT FOUND: #{user_id}"
      return
    end

    Rails.logger.info "USER FOUND: #{user.id}"
    Rails.logger.info "USER EMAIL: #{user.email}"
    Rails.logger.info "USER ROLE: #{user.role}"

    # Always create notification in database
    notification = Notification.create!(
      user_id: user.id,
      title: title,
      message: message,
      notification_type: "leave",
      read: false
    )

    Rails.logger.info "DB NOTIFICATION CREATED: #{notification.id}"

    # Only send push notification if user is logged in
    device_token = DeviceToken.find_by(
      user_id: user.id,
      active: true
    )

    if device_token.present?

      Rails.logger.info " ACTIVE DEVICE TOKEN FOUND"
      Rails.logger.info "TOKEN ID: #{device_token.id}"

      FirebaseNotificationService.send_notification(
        device_token.token,
        title,
        message
      )

      Rails.logger.info " FIREBASE SEND METHOD CALLED"

    else

      Rails.logger.info "USER IS NOT LOGGED IN"
      Rails.logger.info " PUSH NOTIFICATION NOT SENT"

    end
  end
end