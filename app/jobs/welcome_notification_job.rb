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

puts "COMPANY TOKENS: #{tokens.inspect}"

     if tokens.present?

  tokens.each do |token|

    FirebaseNotificationService.send_notification(
      token,
      "Welcome",
      "Welcome #{company.name} to WorkSphere Portal"
    )

  end

else

  puts "No device token found for company #{company.id}"

end


    elsif type == "hr" || type == "employee"


      user = User.find(id)


      # return if Notification.exists?(
      #   user_id: user.id,
      #   notification_type: "welcome"
      # )


      Notification.create!(
        user_id: user.id,
        title: "Welcome",
        message: "Welcome #{user.name} to WorkSphere Portal",
        notification_type: "welcome"
      )


      device_token = DeviceToken.find_by(
        user_id: user.id
      )


      if device_token.present?

        FirebaseNotificationService.send_notification(
          device_token.token,
          "Welcome",
          "Welcome #{user.name} to WorkSphere Portal"
        )

      end


    end   # if type end

  end     # perform end

end       # class end