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

      render json: @hr

    end



def create

  unless current_company
    render json:{
      error:"Company authentication failed"
    }, status: :unauthorized
    return
  end


  hr = User.new(hr_params)

  hr.role = "hr"
  hr.company_id = current_company.id


  if hr.save
    render json:{
      message:"HR added successfully",
      user:hr
    }, status: :created
  else
    render json:{
      errors:hr.errors.full_messages
    }, status: :unprocessable_entity
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


      @hr.destroy


      render json:{
        message:"HR deleted successfully"
      }


    end






    private




    def set_hr


      @hr = User.find_by(
        id: params[:id],
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