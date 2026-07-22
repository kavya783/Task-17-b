class ApplicationController < ActionController::Base

  protect_from_forgery with: :null_session

  attr_reader :current_user
  attr_reader :current_company


  def authenticate_request

    header = request.headers['Authorization']

    unless header
      render json:{
        error:"Token missing"
      }, status: :unauthorized
      return
    end


    token = header.split(' ').last

    decoded = JsonWebToken.decode(token)


    unless decoded
      render json:{
        error:"Unauthorized"
      }, status: :unauthorized
      return
    end



    if decoded[:user_id]

      @current_user = User.find_by(
        id: decoded[:user_id]
      )


    elsif decoded[:company_id]

      @current_company = Company.find_by(
        id: decoded[:company_id]
      )

    end



    unless @current_user || @current_company

      render json:{
        error:"User not found"
      },
      status: :not_found

    end


  end

end