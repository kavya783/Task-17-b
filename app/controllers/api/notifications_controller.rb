module Api
  class NotificationsController < ApplicationController
    before_action :authenticate_request

    # GET /api/notifications
    def index
      if current_company
        notifications = Notification
          .where(company_id: current_company.id)
          .where.not(notification_type: "welcome")
          .preload(:company, :user)
          .order(created_at: :desc)

      elsif current_user
        notifications = Notification
          .where(user_id: current_user.id)
          .where.not(notification_type: "welcome")
          .preload(:user, :company)
          .order(created_at: :desc)

      else
        notifications = Notification.none
      end

      render json: notifications.map { |notification|
        {
          id: notification.id,
          title: notification.title,
          message: notification.message,
          notification_type: notification.notification_type,
          read: notification.read,
          created_at: notification.created_at,
          user_name: notification.user&.name,
          user_email: notification.user&.email
        }
      }
    end

    # GET /api/notifications/welcome
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

    # PATCH /api/notifications/:id/mark_as_read
    def mark_as_read
      notification = Notification.find(params[:id])

      notification.update!(read: true)

      render json: {
        message: "Notification marked as read"
      }
    end

    # POST /api/notifications
    def create
      employee = User.find(params[:employee_id])

      FirebaseNotificationService.send_notification(
        employee.fcm_token,
        params[:title],
        params[:body]
      )

      render json: {
        message: "Notification sent successfully"
      }
    end

    # DELETE /api/notifications/:id
    def destroy
      notification = Notification.find(params[:id])

      notification.destroy!

      render json: {
        message: "Notification deleted successfully"
      }
    end
  end
end