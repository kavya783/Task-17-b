class Api::LeavesController < ApplicationController

  def index
    render json: Leave.all
  end

  def show
    leave = Leave.find(params[:id])
    render json: leave
  end

  def create
    leave = Leave.new(leave_params)

    if leave.save
      render json: leave, status: :created
    else
      render json: { errors: leave.errors.full_messages }, status: :unprocessable_entity
    end
  end

 def update
  leave = Leave.find(params[:id])

  if leave.update(leave_params)
    render json: leave
  else
    render json: { errors: leave.errors.full_messages }, status: :unprocessable_entity
  end
end

  def destroy
    leave = Leave.find(params[:id])
    leave.destroy
    render json: { message: "Deleted successfully" }
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