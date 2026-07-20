module Api
  class DeviceTokensController < ApplicationController

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

  puts "SAVED TOKEN:"
  puts device_token.token
  puts "USER:"
  puts device_token.user_id

  render json:{
    message:"Device token saved"
  }

end
      else
        render json: {
          errors: device_token.errors.full_messages
        }, status: 422
      end
    end

  end
end