module Api
  class UsersController < ApplicationController

    skip_before_action :verify_authenticity_token
    before_action :authenticate_request

    include Rails.application.routes.url_helpers


    # GET /api/users
    def index

      if current_user.role == "company"

        users = User.where(
          company_id: current_user.id,
          role: "hr"
        )

      elsif current_user.role == "hr"

        users = User.where(
          company_id: current_user.company_id,
          role: "employee"
        )

      else

        users = []

      end


      render json: users.map { |user|

        user.as_json.merge(
          profile_image_url:
          user.profile_image.attached? ?
          url_for(user.profile_image) :
          nil
        )

      }

    end



    # GET /api/users/:id
    def show

      user = User.find(params[:id])


      render json: user.as_json.merge(
        profile_image_url:
        user.profile_image.attached? ?
        url_for(user.profile_image) :
        nil
      )

    end




    # POST /api/users
   def create

  Rails.logger.info "CURRENT USER ===== #{current_user.inspect}"

  user = User.new(user_params)


  if user.role == "hr"

    user.company_id = current_user.id

  end


  if user.save

    render json:{
      message:"HR created successfully",
      user:user
    },
    status: :created

  else

    render json:{
      errors:user.errors.full_messages
    },
    status: :unprocessable_entity

  end

end
# PATCH /api/users/:id
    def update


      user = User.find(params[:id])


      if user.update(user_params)


        render json: {

          message: "Updated successfully",

          user: user.as_json.merge(

            profile_image_url:
            user.profile_image.attached? ?
            url_for(user.profile_image) :
            nil

          )

        }


      else


        render json: {

          errors: user.errors.full_messages

        },
        status: :unprocessable_entity


      end


    end
    # DELETE /api/users/:id
    def destroy


      user = User.find(params[:id])


      if user.destroy


        render json: {

          message: "Deleted successfully"

        }


      else


        render json: {

          error: "Delete failed"

        },
        status: :unprocessable_entity
end
    end
 # Save Firebase token
    def save_fcm_token


      user = User.find(params[:user_id])


      if user.update(
        fcm_token: params[:fcm_token]
      )


        render json: {

          message: "FCM token saved successfully"

        }


      else


        render json: {

          errors: user.errors.full_messages

        },
        status: :unprocessable_entity


      end


    end






    private



    def user_params


      params[:role] =
        params[:role].to_s.downcase



      params.permit(

        :name,
        :email,
        :password,
        :role,
        :address,
        :salary,
        :profile_image,
        :company_id

      )


    end


  end
end