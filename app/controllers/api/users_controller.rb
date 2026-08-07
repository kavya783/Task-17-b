module Api
  class UsersController < ApplicationController

    skip_before_action :verify_authenticity_token
    before_action :authenticate_request

    include Rails.application.routes.url_helpers


    # GET /api/users
    def index

      if current_company

        users = User.where(
          company_id: current_company.id,
          role: "hr"
        )

      elsif current_user&.role == "hr"

        users = User.where(
          hr_id: current_user.id,
          role: "employee"
        )

      elsif current_user&.role == "employee"

        users = User.where(
          id: current_user.id
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




   
def create

  user = User.new(user_params)


  if user.role == "hr"
    user.company_id = current_company.id

  elsif user.role == "employee"
    user.company_id = current_user.company_id
    user.hr_id = current_user.id
  end


  if user.save

    attach_compressed_image(user) if params[:profile_image].present?

    render json:{
      message:"#{user.role} created successfully",
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

    attach_compressed_image(user) if params[:profile_image].present?

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

        params[:role] = params[:role].to_s.downcase

        params.permit(
          :name,
          :email,
          :password,
          :role,
          :address,
          :salary,
          :company_id,
          :hr_id
        )

      end


      def attach_compressed_image(user)

        compressed = ImageCompressionService.compress(
          params[:profile_image]
        )

        File.open(compressed.path) do |file|

          user.profile_image.attach(
            io: file,
            filename: "compressed_image.jpg",
            content_type: "image/jpeg"
          )
      end

  end
end
end