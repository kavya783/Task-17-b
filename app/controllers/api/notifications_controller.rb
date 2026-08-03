module Api
  class NotificationsController < ApplicationController

    before_action :authenticate_request

def index
  begin
    Rails.logger.info "Current Company: #{current_company.inspect}"
    Rails.logger.info "Current User: #{current_user.inspect}"

    if current_company
      notifications = Notification.where(company_id: current_company.id)
                                  .where.not(notification_type: "welcome")

    elsif current_user
      notifications = Notification.where(user_id: current_user.id)
                                  .where.not(notification_type: "welcome")

    else
      notifications = []
    end

    render json: notifications.order(created_at: :desc)

  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")

    render json: { error: e.message }, status: :internal_server_error
  end
end

   def welcome

  notification = nil

  if current_company

    notification = Notification.find_by(
      company_id: current_company.id,
      notification_type: "welcome",
      read: false
    )


  elsif current_user

    notification = Notification.find_by(
      user_id: current_user.id,
      notification_type: "welcome",
      read: false
    )

  end


  render json: notification

end


    def mark_as_read

      notification = Notification.find(params[:id])

      notification.update(read: true)

      render json: {
        message: "Notification marked as read"
      }

    end
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
    def destroy

      notification = Notification.find(params[:id])

      notification.destroy

      render json: {
        message: "Notification deleted successfully"
      }

    end

  end
  
end