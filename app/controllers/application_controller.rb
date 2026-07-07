class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    if decoded
      @current_user = User.find(decoded[:user_id])
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end