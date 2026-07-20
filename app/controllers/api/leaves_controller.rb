class Api::LeavesController < ApplicationController

  def index
    leaves = Leave.all

    render json: leaves.map { |leave|
      {
        id: leave.id,
        employeename: leave.employeename,
        email: leave.email,
        leaveType: leave.leaveType,
        from_date: leave.from_date,
        to_date: leave.to_date,
        reason: leave.reason,
        status: leave.status,
        profile_image_url: leave.profileImage
      }
    }
  end


  def show
    leave = Leave.find(params[:id])

    render json: {
      message: "Leave details fetched successfully",
      leave: leave
    }
  end


  def create
    leave = Leave.new(leave_params)

    if leave.save

      hr = User.find_by(role: "hr")

      if hr
        device_token = DeviceToken.find_by(user_id: hr.id)

        if device_token
          FirebaseNotificationService.send_notification(
            device_token.token,
            "New Leave Request",
            "#{leave.employeename} applied for leave"
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

      employee = User.find_by(email: leave.email)

      if employee

        device_token = DeviceToken.find_by(user_id: employee.id)

        if device_token

          if leave.status == "approved"

            FirebaseNotificationService.send_notification(
              device_token.token,
              "Leave Approved",
              "Your leave request has been approved."
            )


          elsif leave.status == "rejected"

            FirebaseNotificationService.send_notification(
              device_token.token,
              "Leave Rejected",
              "Your leave request has been rejected."
            )

          end

        end
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

      render json: {
        message: "Leave deleted successfully"
      }

    else

      render json: {
        errors: "Delete failed"
      }, status: :unprocessable_entity

    end
  end



  private


  def leave_params
    params.require(:leave).permit(
      :employeename,
      :email,
      :leaveType,
      :from_date,
      :to_date,
      :reason,
      :status,
      :profileImage
    )
  end

end