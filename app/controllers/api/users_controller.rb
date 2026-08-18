module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_request

    include Rails.application.routes.url_helpers

    # GET /api/users
    def index
      users =
        if current_company
          User.where(
            company_id: current_company.id,
            role: :hr
          )

        elsif current_user&.role == "hr"
          User.where(
            hr_id: current_user.id,
            role: :employee
          )

        elsif current_user&.role == "employee"
          User.where(
            id: current_user.id
          )

        else
          User.none
        end

      # Optimization:
      # 1. select -> required columns only
      # 2. with_attached_profile_image -> avoid N+1 queries
      # 3. order -> database-level sorting
      users = users
        .select(
          :id,
          :name,
          :email,
          :role,
          :address,
          :salary
        )
        .with_attached_profile_image
        .order(created_at: :desc)

      render json: users.map { |user| serialize_user(user) }
    end

    # GET /api/users/:id
    def show
      user = User
        .select(
          :id,
          :name,
          :email,
          :role,
          :address,
          :salary
        )
        .with_attached_profile_image
        .find_by(id: params[:id])

      unless user
        render json: {
          error: "User not found"
        }, status: :not_found
        return
      end

      render json: serialize_user(user)
    end

    # POST /api/users
   def create
  user = UserService.create(
    user_params,
    current_user,
    current_company
  )

  attach_compressed_image(user) if params[:profile_image].present?

  render json: {
    message: "#{user.role} created successfully",
    user: serialize_user(user)
  }, status: :created

rescue ActiveRecord::RecordInvalid => e
  render json: {
    errors: e.record.errors.full_messages
  }, status: :unprocessable_entity
end

    # PATCH /api/users/:id
    def update
      user = User.find_by(id: params[:id])

      unless user
        render json: {
          error: "User not found"
        }, status: :not_found
        return
      end
if user.update(user_params)

  attach_compressed_image(user) if params[:profile_image].present?

  Rails.cache.delete("company_#{user.company_id}_hrs")

  render json: {
    message: "Updated successfully",
    user: serialize_user(user)
  }

      else
        render json: {
          errors: user.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # DELETE /api/users/:id
   def destroy
  user = User.find_by(id: params[:id])

  unless user
    render json: {
      error: "User not found"
    }, status: :not_found
    return
  end

  company_id = user.company_id
  user_role = user.role

  if user.destroy

    if user_role == "hr"
      Rails.cache.delete("company_#{company_id}_hrs")
    end

    render json: {
      message: "Deleted successfully"
    }
  else
    render json: {
      error: "Delete failed"
    }, status: :unprocessable_entity
  end
end 
    def send_bulk_notification

  EmployeeNotificationJob.perform_later(
    current_company.id
  )

  render json: {
    message: "Notification job started successfully"
  }

end

    # Save Firebase token
    def save_fcm_token
      user = User.find_by(id: params[:user_id])

      unless user
        render json: {
          error: "User not found"
        }, status: :not_found
        return
      end

      if user.update(fcm_token: params[:fcm_token])
        render json: {
          message: "FCM token saved successfully"
        }
      else
        render json: {
          errors: user.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    private

    # Strong parameters
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

    # Common user JSON response
    def serialize_user(user)
      user.as_json.merge(
        profile_image_url: profile_image_url(user)
      )
    end

    # Profile image URL
    def profile_image_url(user)
      return nil unless user.profile_image.attached?

      url_for(user.profile_image)
    end

    # Compress and attach profile image
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