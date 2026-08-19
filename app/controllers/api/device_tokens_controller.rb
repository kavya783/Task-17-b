module Api
  class DeviceTokensController < ApplicationController

    before_action :authenticate_request

    def create

      if current_user

        device_token =
          DeviceToken.find_or_initialize_by(
            user_id: current_user.id
          )

        device_token.company_id = nil

      elsif current_company

        device_token =
          DeviceToken.find_or_initialize_by(
            company_id: current_company.id
          )

        device_token.user_id = nil

      else

        return render json: {
          error: "User or company not found"
        }, status: :unauthorized

      end

      token = params[:token].presence

      if token.blank?

        return render json: {
          error: "FCM token is required"
        }, status: :unprocessable_entity

      end

      device_token.token = token

      if device_token.save

        Rails.logger.info(
          "FCM token saved successfully for " \
          "#{current_user ? "user #{current_user.id}" : "company #{current_company.id}"}"
        )

        render json: {
          message: "Device token saved",
          token_id: device_token.id
        }, status: :ok

      else

        render json: {
          errors: device_token.errors.full_messages
        }, status: :unprocessable_entity

      end

    end

  end
end