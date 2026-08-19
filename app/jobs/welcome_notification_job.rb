class WelcomeNotificationJob < ApplicationJob

  queue_as :default


  def perform(id, type)

    case type


    # ==================================================
    # COMPANY
    # ==================================================

    when "company"

      company = Company.find(id)


      # -----------------------------------------------
      # Create welcome notification
      # -----------------------------------------------

      Notification.create!(
        company_id: company.id,

        title: "Welcome",

        message:
          "Welcome #{company.name} to WorkSphere Portal",

        notification_type: "welcome"
      )


      # -----------------------------------------------
      # Get company device tokens
      # -----------------------------------------------

      tokens =
        DeviceToken
          .where(company_id: company.id)
          .where.not(token: [nil, ""])
          .pluck(:token)
          .uniq


      # -----------------------------------------------
      # Send notification
      # -----------------------------------------------

      tokens.each do |token|

        FirebaseNotificationService.send_notification(
          token,

          "Welcome",

          "Welcome #{company.name} to WorkSphere Portal"
        )

      end


    # ==================================================
    # HR / EMPLOYEE
    # ==================================================

    when "hr", "employee"

      user = User.find(id)


      # -----------------------------------------------
      # Create welcome notification
      # -----------------------------------------------

      Notification.create!(
        user_id: user.id,

        title: "Welcome",

        message:
          "Welcome #{user.name} to WorkSphere Portal",

        notification_type: "welcome"
      )


      # -----------------------------------------------
      # Get user device token
      # -----------------------------------------------

      device_token =
        DeviceToken.find_by(
          user_id: user.id
        )


      # -----------------------------------------------
      # Send notification
      # -----------------------------------------------

      if device_token.present? &&
         device_token.token.present?

        FirebaseNotificationService.send_notification(
          device_token.token,

          "Welcome",

          "Welcome #{user.name} to WorkSphere Portal"
        )

      end

    end

  rescue ActiveRecord::RecordNotFound => error

    Rails.logger.error(
      "WelcomeNotificationJob record not found: #{error.message}"
    )

  rescue StandardError => error

    Rails.logger.error(
      "WelcomeNotificationJob failed: #{error.message}"
    )

  end

end