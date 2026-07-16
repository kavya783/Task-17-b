class Api::DeviceTokensController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create

    device_token = DeviceToken.find_or_initialize_by(
      user_id: params[:user_id]
    )

    device_token.token = params[:token]

    if device_token.save

      render json: {
        message: "Token saved successfully",
        device_token: device_token
      }, status: :ok

    else

      render json: {
        errors: device_token.errors.full_messages
      }, status: :unprocessable_entity

    end

  end
end