module Api
  class AuthController < ApplicationController
    skip_before_action :verify_authenticity_token

    def signup
      user = User.new(user_params)

      if user.save
        render json: {
          message: "Signup success",
          user: user
        }, status: :created
      else
        render json: {
          error: user.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

  def login
  user = User.find_by(email: params[:email])

  if user&.authenticate(params[:password])

    puts "LOGIN METHOD CALLED"
    puts "ROLE: #{user.role}"

    tokens = DeviceToken.where(user_id: user.id).pluck(:token)

    puts "TOKENS: #{tokens.inspect}"

    tokens.each do |token|
      FirebaseNotificationService.send_notification(
        token,
        "Login Successful",
        "Welcome #{user.role.capitalize}"
      )
    end

    puts "NOTIFICATION METHOD FINISHED"

    render json: {
      message: "Login success",
      user_id: user.id,
      user: user,
      role: user.role
    }, status: :ok

  else
    render json: {
      error: "Invalid email or password"
    }, status: :unauthorized
  end
end
    private

    def user_params
      params.permit(:name, :email, :password, :role)
    end
  end
end