class Api::DeviceTokensController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: DeviceToken.all
  end


  def create

    device_token = DeviceToken.find_or_initialize_by(
      user_id: params[:user_id]
    )

    device_token.token = params[:token]

    if device_token.save

      render json: {
        message: "Device token saved"
      }

    else

      render json: {
        errors: device_token.errors.full_messages
      }, status: 422

    end

  end

end