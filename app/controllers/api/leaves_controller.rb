module Api
  class LeavesController < ApplicationController
    before_action :authenticate_request


  def index
    applied_by = params[:applied_by].presence

    # determine company context from user or company token
    company_id = current_user&.company_id || current_company&.id

    leaves = if current_user&.role == "hr"
               if applied_by == "employee" || applied_by.blank?
                 employee_ids = company_id.present? ? User.where(company_id: company_id, role: "employee").pluck(:id) : []
                 Leave.where(leaveable_type: "User", leaveable_id: employee_ids).order(created_at: :desc)
               else
                 Leave.where(leaveable_type: "User", leaveable_id: current_user.id).order(created_at: :desc)
               end
      elsif current_user&.role == "employee"

        leaves = Leave.where(
          leaveable_type: "User",
          leaveable_id: current_user.id
        ).order(created_at: :desc)
                  elsif current_company.present?
                    if applied_by == "employee"
                      employee_ids = User.where(company_id: current_company.id, role: "employee").pluck(:id)
                      Leave.where(leaveable_type: "User", leaveable_id: employee_ids).order(created_at: :desc)
                    else
                      hr_ids = User.where(company_id: current_company.id, role: "hr").pluck(:id)
                      Leave.where(leaveable_type: "User", leaveable_id: hr_ids).order(created_at: :desc)
                    end
                  else
                    Leave.none
                  end

          render json: leaves.map { |leave|
            user = leave.leaveable

          {
            id: leave.id,
            employeename: leave.employeename || user&.name,
            email: user&.email,
            leaveType: leave.leaveType,
            from_date: leave.from_date,
            to_date: leave.to_date,
            reason: leave.reason,
            status: (leave.status.presence || "pending").downcase,
            profile_image_url: leave.profileImage
          }
        }
  end
    def show

      leave = Leave.find(params[:id])

      render json:{
        message:"Leave details fetched successfully",
        leave:leave
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
      LeaveNotificationJob.perform_later(
        hr.id,
        "New Leave Request",
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

    end




    def update

      leave = Leave.find(params[:id])


     if leave.update(leave_params)
  employee = leave.leaveable

  if employee
    LeaveNotificationJob.perform_later(
      employee.id,
      "Leave #{leave.status}",
      "Your leave request has been #{leave.status}"
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
