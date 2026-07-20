class Api::DeviceTokensController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    
    DeviceToken.where(user_id: params[:user_id]).delete_all

    # save latest device token
    device_token = DeviceToken.create(
      user_id: params[:user_id],
      token: params[:token]
    )

    if device_token.persisted?
      render json: {
        message: "Latest device token saved"
      }
    else
      render json: {
        errors: device_token.errors.full_messages
      }, status: 422
    end

  end
end