  module Api

    class HrsController < ApplicationController

      skip_before_action :verify_authenticity_token
      before_action :authenticate_request
      before_action :set_hr, only: [:show, :update, :destroy]


 def index
  company_id = current_user&.company_id || current_company&.id

  puts "CURRENT USER ID: #{current_user&.id}"
  puts "CURRENT USER COMPANY ID: #{current_user&.company_id}"
  puts "CURRENT COMPANY ID: #{current_company&.id}"
  puts "FINAL COMPANY ID: #{company_id}"

  if company_id.present?

    hrs = Rails.cache.fetch(
      "company_#{company_id}_hrs",
      expires_in: 10.minutes
    ) do
     puts "========== CACHE MISS =========="
      User
        .joins(:company)
        .where(
          companies: { id: company_id },
          role: :hr
        )
        .with_attached_profile_image
        .order(created_at: :desc)
        .map do |hr|
          {
            id: hr.id,
            name: hr.name,
            email: hr.email,
            address: hr.address,
            role: hr.role,
            profile_image_url:
              hr.profile_image.attached? ? url_for(hr.profile_image) : nil
          }
        end

    end

    render json: hrs

  else

    render json: []

  end
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

        Rails.cache.delete("company_#{hr.company_id}_hrs")

        begin
          UserMailer
            .hr_created(hr)
            .deliver_now
        rescue => e
          Rails.logger.error(
            "HR creation email failed: #{e.class} - #{e.message}"
          )
        end

        render json: {
          message: "HR added successfully",
          user: hr
        }, status: :created

      else
        render json: {
          errors: hr.errors.full_messages
        }, status: :unprocessable_entity
end

      end





      def update


      if @hr.update(hr_params)

    attach_compressed_image(@hr) if params[:profile_image].present?

    Rails.cache.delete("company_#{@hr.company_id}_hrs")

    render json: {
      message: "HR updated successfully",
      user: @hr
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

    company_id = @hr.company_id

  if @hr.destroy

    Rails.cache.delete("company_#{company_id}_hrs")

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