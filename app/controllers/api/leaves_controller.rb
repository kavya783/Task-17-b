module Api
  class LeavesController < ApplicationController
    before_action :authenticate_request


def index
  applied_by = params[:applied_by].presence

  company_id = current_user&.company_id || current_company&.id

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

Rails.logger.info "🔥 FINAL LEAVE RESPONSE: #{result.inspect}"

render json: result
end
  def show
  leave = Leave
    .includes(:leaveable)
    .find_by(id: params[:id])

  unless leave
    render json: { error: "Leave not found" }, status: :not_found
    return
  end

  user = leave.leaveable

  profile_image_url =
    if user&.profile_image&.attached?
      url_for(user.profile_image)
    end

  render json: {
    message: "Leave details fetched successfully",
    leave: {
      id: leave.id,
      employeename: user&.name || leave.employeename,
      email: user&.email,
      leaveType: leave.leaveType,
      from_date: leave.from_date,
      to_date: leave.to_date,
      reason: leave.reason,
      status: leave.status.presence || "pending",
      profile_image_url: profile_image_url
    }
  }
end



    def create

      leave = Leave.new(leave_params)

      leave.leaveable = current_user
      leave.company_id = current_user&.company_id || current_company&.id

      if leave.company_id.blank?
        render json: { error: "Company not found" }, status: :unprocessable_entity
        return
      end

      if leave.save


        if current_user.role == "employee"

          hr = User.find_by(id: current_user.hr_id)

          if hr

            UserMailer
              .leave_notification(hr, leave)
              .deliver_now


          LeaveNotificationJob.perform_later(
  hr.id,
  "New Leave Request",
  "#{current_user.name} applied for leave"
)
          end

        end


        render json:{
          message:"Leave applied successfully",
          leave:leave
        },
        status: :created


      else

        render json:{
          errors:leave.errors.full_messages
        },
        status: :unprocessable_entity

      end

    end




   def update
  leave = Leave.find_by(id: params[:id])

  unless leave
    render json: { error: "Leave not found" }, status: :not_found
    return
  end

  if leave.update(leave_params)
    employee = leave.leaveable

    if employee
      begin
        UserMailer
          .leave_status_notification(employee, leave)
          .deliver_now
      rescue => e
        Rails.logger.error "Leave status mail failed: #{e.class} - #{e.message}"
      end

      begin
        LeaveNotificationJob.perform_later(
          employee.id,
          "Leave #{leave.status}",
          "Your leave request has been #{leave.status}"
        )
      rescue => e
        Rails.logger.error "Leave notification job failed: #{e.class} - #{e.message}"
      end
    end

    render json: {
      message: "Leave updated successfully",
      leave: {
        id: leave.id,
        employeename: employee&.name || leave.employeename,
        email: employee&.email,
        leaveType: leave.leaveType,
        from_date: leave.from_date,
        to_date: leave.to_date,
        reason: leave.reason,
        status: leave.status
      }
    }, status: :ok

  else
    render json: {
      errors: leave.errors.full_messages
    }, status: :unprocessable_entity
  end

rescue ActionController::ParameterMissing => e
  render json: {
    error: e.message
  }, status: :bad_request

rescue => e
  Rails.logger.error "Leave update error: #{e.class} - #{e.message}"
  Rails.logger.error e.backtrace.first(10).join("\n")

  render json: {
    error: "Unable to update leave",
    details: e.message
  }, status: :internal_server_error
end



    def destroy

      leave = Leave.find(params[:id])


      if leave.destroy

        render json:{
          message:"Leave deleted successfully"
        }

      else

        render json:{
          error:"Delete failed"
        },
        status: :unprocessable_entity

      end

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
