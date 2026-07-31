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
 
  
      company = Company.find_by(email: params[:email])

      if company && company.authenticate(params[:password])

        token = JsonWebToken.encode(company_id: company.id)

        WelcomeNotificationJob
          .set(wait: 15.seconds)
          .perform_later(company.id, "company")


        render json: {
          message: "Login successful",
          token: token,
          type: "company",
          company: company
        }

        return
      end


     
      user = User.find_by(email: params[:email])

      if user && user.authenticate(params[:password])

        token = JsonWebToken.encode(user_id: user.id)


  
       if user.role == "hr"

          WelcomeNotificationJob
            .set(wait: 15.seconds)
            .perform_later(user.id, "hr")

        elsif user.role == "employee"

          WelcomeNotificationJob
          .set(wait: 15.seconds)
            .perform_later(user.id, "employee")

        end


                render json: {
                  message: "Login successful",
                  token: token,
                  type: "user",
                  role: user.role,
                  user: user
                }

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