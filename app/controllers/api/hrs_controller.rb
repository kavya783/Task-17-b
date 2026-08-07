module Api

  class HrsController < ApplicationController

    skip_before_action :verify_authenticity_token
    before_action :authenticate_request
    before_action :set_hr, only: [:show, :update, :destroy]


    def index
      company_id = current_user&.company_id || current_company&.id

      hrs = if company_id.present?
              User.where(company_id: company_id, role: :hr)
            else
              User.none
            end

      render json: hrs.map { |hr|
        {
          id: hr.id,
          name: hr.name,
          email: hr.email,
          address: hr.address,
          role: hr.role,
          profile_image_url: hr.profile_image.attached? ? url_for(hr.profile_image) : nil
        }
      }
    end



    def show

      render json:@hr

    end



    def create

      hr = User.new(hr_params)

      hr.role = "hr"
      hr.company_id = current_user&.company_id || current_company&.id

      if hr.company_id.blank?
        render json: { error: "Company not found" }, status: :unprocessable_entity
        return
      end

      if hr.save
        attach_compressed_image(hr) if params[:profile_image].present?


        # HR welcome mail

        UserMailer
          .hr_created(hr)
          .deliver_now



        render json:{
          message:"HR added successfully",
          user:hr
        },
        status: :created


      else


        render json:{
          errors:hr.errors.full_messages
        },
        status: :unprocessable_entity


      end

    end





    def update


      if @hr.update(hr_params)
        attach_compressed_image(@hr) if params[:profile_image].present?

        render json:{
          message:"HR updated successfully",
          user:@hr
        }


      else


        render json:{
          errors:@hr.errors.full_messages
        },
        status: :unprocessable_entity


      end


    end





def destroy
  hr_email = @hr.email
  hr_name = @hr.name

  if @hr.destroy
    UserMailer.hr_deleted(hr_email, hr_name).deliver_now

    render json: {
      message: "HR deleted successfully"
    }
  else
    render json: {
      errors: @hr.errors.full_messages
    }, status: :unprocessable_entity
  end
end





    private



    def set_hr


      @hr = User.find_by(
        id:params[:id],
        role:"hr"
      )


      unless @hr

        render json:{
          error:"HR not found"
        },
        status: :not_found

      end


    end




    def hr_params

      params.permit(
        :name,
        :email,
        :password,
        :address
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
    ensure
      compressed&.close!
    end

  end

end