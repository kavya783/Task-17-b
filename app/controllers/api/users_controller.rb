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
  Rails.logger.info "PARAMS: #{params.inspect}"
  Rails.logger.info "PROFILE IMAGE: #{params[:profile_image].inspect}"

  user = User.new(user_params)

  if user.save
    render json: {
      message: "Employee Added Successfully",
      user: user
    }, status: :created
  else
    render json: {
      message: user.errors.full_messages.join(", ")
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
      message: "Employee Updated Successfully",
      user: user
    }
  else
    render json: {
      message: user.errors.full_messages.join(", ")
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