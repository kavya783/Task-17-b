module Api
  class NotificationsController < ApplicationController

    def create

      employee = Employee.find(params[:employee_id])

      FirebaseNotificationService.send_notification(
        employee.fcm_token,
        params[:title],
        params[:body]
      )

      render json: {
        message: "Notification sent successfully"
      }

    end

  end
end