module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        employee = Employee.find_by(email: params[:email])

        if employee&.authenticate(params[:password])
          render json: {
            success: true,
            message: "Login Successful",
            employee: {
              id: employee.id,
              name: employee.name,
              email: employee.email,
              role: employee.role
            }
          }, status: :ok
        else
          render json: {
            success: false,
            message: "Invalid Email or Password"
          }, status: :unauthorized
        end
      end
    end
  end
end