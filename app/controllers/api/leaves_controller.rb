module Api
  class LeavesController < ApplicationController
    before_action :authenticate_request

    def index
      applied_by = params[:applied_by].presence

      company_id =
        current_user&.company_id || current_company&.id

      leaves =
        if current_user&.role == "hr"

          if applied_by == "employee" || applied_by.blank?

            employee_ids =
              if company_id.present?
                User.where(
                  company_id: company_id,
                  role: :employee
                ).pluck(:id)
              else
                []
              end

            Leave
              .where(
                leaveable_type: "User",
                leaveable_id: employee_ids
              )
              .includes(:leaveable)
              .recent

          else

            Leave
              .where(
                leaveable_type: "User",
                leaveable_id: current_user.id
              )
              .includes(:leaveable)
              .recent

          end

        elsif current_user&.role == "employee"

          Leave
            .where(
              leaveable_type: "User",
              leaveable_id: current_user.id
            )
            .includes(:leaveable)
            .order(created_at: :desc)

        elsif current_company.present?

          if applied_by == "employee"

            employee_ids = User
              .where(
                company_id: current_company.id,
                role: :employee
              )
              .pluck(:id)

            Leave
              .where(
                leaveable_type: "User",
                leaveable_id: employee_ids
              )
              .includes(:leaveable)
              .order(created_at: :desc)

          else

            hr_ids = User
              .where(
                company_id: current_company.id,
                role: :hr
              )
              .pluck(:id)

            Leave
              .where(
                leaveable_type: "User",
                leaveable_id: hr_ids
              )
              .includes(:leaveable)
              .order(created_at: :desc)

          end

        else

          Leave.none

        end

      result = leaves.map do |leave|
        user = leave.leaveable

        {
          id: leave.id,
          employeename: user&.name || leave.employeename,
          email: user&.email,
          leaveType: leave.leaveType,
          from_date: leave.from_date,
          to_date: leave.to_date,
          reason: leave.reason,
          status: leave.status.presence || "pending"
        }
      end

      render json: result

    rescue StandardError => e

      Rails.logger.error(
        "LEAVES INDEX ERROR: #{e.class} - #{e.message}"
      )

      Rails.logger.error(
        e.backtrace.first(10).join("\n")
      )

      render json: {
        error: "Failed to fetch leaves",
        message: e.message
      }, status: :internal_server_error

    end


    def show
      leave = Leave
        .includes(:leaveable)
        .find_by(id: params[:id])

      unless leave
        render json: {
          error: "Leave not found"
        }, status: :not_found

        return
      end

      user = leave.leaveable

      profile_image_url = nil

      if user&.profile_image&.attached?
        profile_image_url = url_for(user.profile_image)
      end

      render json: {
        message: "Leave details fetched successfully",

        leave: {
          id: leave.id,

          employeename:
            user&.name || leave.employeename,

          email:
            user&.email,

          leaveType:
            leave.leaveType,

          from_date:
            leave.from_date,

          to_date:
            leave.to_date,

          reason:
            leave.reason,

          status:
            leave.status.presence || "pending",

          profile_image_url:
            profile_image_url
        }
      }

    rescue StandardError => e

      Rails.logger.error(
        "LEAVE SHOW ERROR: #{e.class} - #{e.message}"
      )

      render json: {
        error: "Failed to fetch leave details"
      }, status: :internal_server_error

    end


    def create
      leave = Leave.new(leave_params)

      leave.leaveable = current_user

      leave.company_id =
        current_user&.company_id ||
        current_company&.id

      if leave.company_id.blank?

        render json: {
          error: "Company not found"
        }, status: :unprocessable_entity

        return

      end

      if leave.save

        # =========================================
        # EMPLOYEE APPLIES LEAVE
        # =========================================

        if current_user&.role == "employee"

          hr = User.find_by(
            id: current_user.hr_id
          )

          if hr

            LeaveNotificationJob.perform_later(
              hr.id,
              "New Leave Request",
              "#{current_user.name} applied for leave",
              leave.id,
              "applied"
            )

          end


        # =========================================
        # HR APPLIES LEAVE
        # =========================================

        elsif current_user&.role == "hr"

          company = Company.find_by(
            id: current_user.company_id
          )

          if company

            # Create notification for company

            Notification.create!(
              company_id: company.id,

              title:
                "New HR Leave Request",

              message:
                "#{current_user.name} applied for leave",

              notification_type:
                "leave",

              read: false,

              leave_id:
                leave.id,

              action:
                "applied",

              applied_by:
                "hr"
            )


            # Send Firebase notification

            FirebaseNotificationService
              .send_notification_to_company(
                company.id,

                "New HR Leave Request",

                "#{current_user.name} applied for leave"
              )

          end

        end


        render json: {
          message: "Leave applied successfully",
          leave: leave
        }, status: :created

      else

        render json: {
          errors: leave.errors.full_messages
        }, status: :unprocessable_entity

      end

    rescue StandardError => e

      Rails.logger.error(
        "LEAVE CREATE ERROR: #{e.class} - #{e.message}"
      )

      Rails.logger.error(
        e.backtrace.first(10).join("\n")
      )

      render json: {
        error: "Failed to create leave",
        message: e.message
      }, status: :internal_server_error

    end


    def update
      leave = Leave.find(params[:id])

      if leave.update(leave_params)

        employee = leave.leaveable

        if employee

          # =========================================
          # SEND NOTIFICATION AFTER APPROVE / REJECT
          # =========================================

          LeaveNotificationJob.perform_later(
            employee.id,

            "Leave #{leave.status}",

            "Your leave request has been #{leave.status}",

            leave.id,

            leave.status
          )

        end


        render json: {
          message: "Leave updated successfully",
          leave: leave
        }

      else

        render json: {
          errors: leave.errors.full_messages
        }, status: :unprocessable_entity

      end

    rescue ActiveRecord::RecordNotFound

      render json: {
        error: "Leave not found"
      }, status: :not_found

    rescue StandardError => e

      Rails.logger.error(
        "LEAVE UPDATE ERROR: #{e.class} - #{e.message}"
      )

      render json: {
        error: "Failed to update leave",
        message: e.message
      }, status: :internal_server_error

    end


    def destroy
      leave = Leave.find(params[:id])

      if leave.destroy

        render json: {
          message: "Leave deleted successfully"
        }

      else

        render json: {
          error: "Delete failed"
        }, status: :unprocessable_entity

      end

    rescue ActiveRecord::RecordNotFound

      render json: {
        error: "Leave not found"
      }, status: :not_found

    rescue StandardError => e

      Rails.logger.error(
        "LEAVE DELETE ERROR: #{e.class} - #{e.message}"
      )

      render json: {
        error: "Failed to delete leave"
      }, status: :internal_server_error

    end


    private


    def leave_params
      params.require(:leave).permit(
        :employeename,
        :leaveType,
        :from_date,
        :to_date,
        :reason,
        :status,
        :profileImage
      )
    end

  end
end