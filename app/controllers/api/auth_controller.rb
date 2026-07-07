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
        render json: {
          message: "Login success",
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