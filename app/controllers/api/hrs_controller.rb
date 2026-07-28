module Api

  class HrsController < ApplicationController

    skip_before_action :verify_authenticity_token
    before_action :authenticate_request
    before_action :set_hr, only: [:show, :update, :destroy]


    def index

      hrs = User.where(
        company_id: current_company.id,
        role: User.roles[:hr]
      )

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
  hr.company_id = current_company.id


  if hr.save

 begin
  UserMailer.hr_created(hr).deliver_now
  Rails.logger.info "========== MAIL SENT SUCCESSFULLY =========="
rescue => e
  Rails.logger.error "========== MAIL ERROR =========="
  Rails.logger.error e.class.to_s
  Rails.logger.error e.message
  Rails.logger.error e.backtrace.first(10)
end

  render json:{
    message:"HR added successfully",
    user:hr
  },
  status: :created

else
    render json:{
      errors: hr.errors.full_messages
    },
    status: :unprocessable_entity

  end

end





    def update


      if @hr.update(hr_params)

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

  begin

    if @hr.destroy

      Rails.logger.info "HR DELETED SUCCESSFULLY"

      UserMailer.hr_deleted(
        hr_email,
        hr_name
      ).deliver_now

      Rails.logger.info "DELETE MAIL SENT SUCCESSFULLY"

      render json:{
        message:"HR deleted successfully"
      }

    else

      render json:{
        error:"HR delete failed"
      }, status: :unprocessable_entity

    end

  rescue => e

    Rails.logger.error "DELETE ERROR: #{e.class}"
    Rails.logger.error e.message

    render json:{
      error:e.message
    }, status:500

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
        :address,
        :profile_image
      )

    end


  end

end