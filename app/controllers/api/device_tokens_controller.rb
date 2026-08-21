module Api
  class DeviceTokensController < ApplicationController

    before_action :authenticate_request

    def create

      if current_user

        device_token = DeviceToken.find_or_initialize_by(
          user_id: current_user.id
        )

      elsif current_company

        device_token = DeviceToken.find_or_initialize_by(
          company_id: current_company.id
        )

      else

        return render json: {
          error: "User or company not found"
        }, status: :unauthorized

      end

      device_token.token = params[:token]
      device_token.active = true

      if device_token.save

        render json: {
          message: "Device token saved successfully"
        }, status: :ok

      else

        render json: {
          errors: device_token.errors.full_messages
        }, status: :unprocessable_entity

      end
    end

  end
end