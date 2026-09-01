class LeaveNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, message, leave_id = nil, action = nil)
    Rails.logger.info "========================================"
    Rails.logger.info "LEAVE NOTIFICATION JOB STARTED"
    Rails.logger.info "USER ID: #{user_id}"
    Rails.logger.info "TITLE: #{title}"
    Rails.logger.info "MESSAGE: #{message}"
    Rails.logger.info "LEAVE ID: #{leave_id}"
    Rails.logger.info "ACTION: #{action}"

    user = User.find_by(id: user_id)

    unless user
      Rails.logger.error "USER NOT FOUND: #{user_id}"
      return
    end

    applied_by =
      case user.role.to_s
      when "hr"
        "hr"
      when "employee"
        "employee"
      end

    notification = Notification.create!(
      user_id: user.id,
      title: title,
      message: message,
      notification_type: "leave",
      read: false,
      leave_id: leave_id,
      action: action,
      applied_by: applied_by
    )

    Rails.logger.info "NOTIFICATION CREATED: #{notification.id}"

    device_token = DeviceToken.find_by(
      user_id: user.id,
      active: true
    )

    if device_token.present?
      FirebaseNotificationService.send_notification(
        device_token.token,
        title,
        message
      )

      Rails.logger.info "FIREBASE NOTIFICATION SENT"
    else
      Rails.logger.info "NO ACTIVE DEVICE TOKEN"
    end

    Rails.logger.info "LEAVE NOTIFICATION JOB COMPLETED"
    Rails.logger.info "========================================"
  end
end