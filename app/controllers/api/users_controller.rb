module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
  include Rails.application.routes.url_helpers
    def index
  users = User.all

  render json: users.map { |user|
    user.as_json.merge(
      profile_image_url: user.profile_image.attached? ?
        url_for(user.profile_image) : nil
    )
  }
end

  def create
  user = User.new(user_params)

  if user.save
    render json: {
      message: "Employee added successfully",
      user: user.as_json.merge(
        profile_image_url: user.profile_image.attached? ? url_for(user.profile_image) : nil
      )
    }, status: :created
  else
    render json: {
      errors: user.errors.full_messages
    }, status: :unprocessable_entity
  end
end
    def show
  user = User.find(params[:id])
  render json: user
end
def update
  user = User.find(params[:id])

  if user.update(user_params)
    render json: {
      message: "Employee updated successfully",
      user: user.as_json.merge(
        profile_image_url: user.profile_image.attached? ? url_for(user.profile_image) : nil
      )
    }
  else
    render json: {
      errors: user.errors.full_messages
    }, status: :unprocessable_entity
  end
end
def save_fcm_token
  user = User.find(params[:user_id])

  if user.update(fcm_token: params[:fcm_token])
    render json: {
      message: "FCM token saved successfully",
      fcm_token: user.fcm_token
    }
  else
    render json: {
      errors: user.errors.full_messages
    }, status: :unprocessable_entity
  end
end
    def destroy
  user = User.find(params[:id])

  if user.destroy
    render json: { message: "Deleted successfully" }
  else
    render json: { error: "Delete failed" }, status: :unprocessable_entity
  end
end

    private

   def user_params
  params[:role] = params[:role].to_s.downcase

  params.permit(:name, :email, :password, :role, :address, :salary, :profile_image)
end
  end
end