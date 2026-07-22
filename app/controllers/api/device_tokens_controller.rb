module Api
  class DeviceTokensController < ApplicationController

    before_action :authenticate_request

    def create

      device_token = DeviceToken.find_or_initialize_by(
        user_id: params[:user_id]
      )

      device_token.token = params[:token]

      if device_token.save

        render json: {
          message: "Device token saved",
          device_token: device_token
        }

      else

        render json: {
          errors: device_token.errors.full_messages
        }, status: :unprocessable_entity

      end

    end

  end
end