module Api
  class LeavesController < ApplicationController
    before_action :authenticate_request

    # GET /api/leaves
    def index
      applied_by = params[:applied_by].presence
      company_id = current_user&.company_id || current_company&.id

      leaves =
        case current_user&.role
        when "hr"
          hr_leaves(company_id, applied_by)

        when "employee"
          employee_leaves

        else
          company_leaves(company_id, applied_by)
        end

      # Pagination
      page = params.fetch(:page, 1).to_i
      per_page = params.fetch(:per_page, 10).to_i.clamp(1, 50)

      leaves = leaves
        .page(page)
        .per(per_page)

      result = leaves.map do |leave|
        user = leave.leaveable

        {
          id: leave.id,
          employeename: user&.name || leave.employeename,
          email: user&.email,
          leaveType: leave.leaveType,
          from_date: leave.from_date,
          to_date: leave.to_date,
          reason: leave.reason,
          status: leave.status.presence || "pending"
        }
      end

      render json: {
        leaves: result,
        current_page: leaves.current_page,
        total_pages: leaves.total_pages,
        total_count: leaves.total_count,
        per_page: leaves.limit_value
      }, status: :ok
    end

    # GET /api/leaves/:id
    def show
      leave = Leave
        .includes(:leaveable)
        .find_by(id: params[:id])

      unless leave
        render json: {
          error: "Leave not found"
        }, status: :not_found
        return
      end

      user = leave.leaveable

      profile_image_url =
        if user&.profile_image&.attached?
          url_for(user.profile_image)
        end

      render json: {
        message: "Leave details fetched successfully",
        leave: {
          id: leave.id,
          employeename: user&.name || leave.employeename,
          email: user&.email,
          leaveType: leave.leaveType,
          from_date: leave.from_date,
          to_date: leave.to_date,
          reason: leave.reason,
          status: leave.status.presence || "pending",
          profile_image_url: profile_image_url
        }
      }, status: :ok
    end

    # POST /api/leaves
    def create
      leave = Leave.new(leave_params)

      leave.leaveable = current_user
      leave.company_id = current_user&.company_id || current_company&.id

      if leave.company_id.blank?
        render json: {
          error: "Company not found"
        }, status: :unprocessable_entity
        return
      end

      if leave.save

        if current_user&.role == "employee"

          hr = User.find_by(id: current_user.hr_id)

          if hr

            # Email should not make API fail
            begin
              UserMailer
                .leave_notification(hr, leave)
                .deliver_now
            rescue => e
              Rails.logger.error(
                "Leave notification mail failed: #{e.class} - #{e.message}"
              )
            end

            # Background notification
            begin
              LeaveNotificationJob.perform_later(
                hr.id,
                "New Leave Request",
                "#{current_user.name} applied for leave"
              )
            rescue => e
              Rails.logger.error(
                "Leave notification job failed: #{e.class} - #{e.message}"
              )
            end

          end
        end

        render json: {
          message: "Leave applied successfully",
          leave: leave
        }, status: :created

      else

        render json: {
          errors: leave.errors.full_messages
        }, status: :unprocessable_entity

      end
    end

    # PUT /api/leaves/:id
    def update
      leave = Leave.find_by(id: params[:id])

      unless leave
        render json: {
          error: "Leave not found"
        }, status: :not_found
        return
      end

      if leave.update(leave_params)

        employee = leave.leaveable

        if employee

          begin
            UserMailer
              .leave_status_notification(employee, leave)
              .deliver_now
          rescue => e
            Rails.logger.error(
              "Leave status mail failed: #{e.class} - #{e.message}"
            )
          end

          begin
            LeaveNotificationJob.perform_later(
              employee.id,
              "Leave #{leave.status}",
              "Your leave request has been #{leave.status}"
            )
          rescue => e
            Rails.logger.error(
              "Leave notification job failed: #{e.class} - #{e.message}"
            )
          end

        end

        render json: {
          message: "Leave updated successfully",
          leave: {
            id: leave.id,
            employeename: employee&.name || leave.employeename,
            email: employee&.email,
            leaveType: leave.leaveType,
            from_date: leave.from_date,
            to_date: leave.to_date,
            reason: leave.reason,
            status: leave.status.presence || "pending"
          }
        }, status: :ok

      else

        render json: {
          errors: leave.errors.full_messages
        }, status: :unprocessable_entity

      end

    rescue ActionController::ParameterMissing => e

      render json: {
        error: e.message
      }, status: :bad_request

    rescue => e

      Rails.logger.error(
        "Leave update error: #{e.class} - #{e.message}"
      )

      Rails.logger.error(
        e.backtrace.first(10).join("\n")
      )

      render json: {
        error: "Unable to update leave"
      }, status: :internal_server_error
    end

    # DELETE /api/leaves/:id
    def destroy
      leave = Leave.find_by(id: params[:id])

      unless leave
        render json: {
          error: "Leave not found"
        }, status: :not_found
        return
      end

      if leave.destroy

        render json: {
          message: "Leave deleted successfully"
        }, status: :ok

      else

        render json: {
          error: "Delete failed"
        }, status: :unprocessable_entity

      end
    end

    private

    # ----------------------------------------
    # HR LEAVES
    # ----------------------------------------

    def hr_leaves(company_id, applied_by)
      if applied_by == "employee" || applied_by.blank?

        Leave
          .select(
            :id,
            :employeename,
            :leaveType,
            :from_date,
            :to_date,
            :reason,
            :status,
            :leaveable_id,
            :leaveable_type,
            :created_at
          )
          .joins(
            "INNER JOIN users ON users.id = leaves.leaveable_id"
          )
          .where(
            leaveable_type: "User",
            users: {
              company_id: company_id,
              role: User.roles[:employee]
            }
          )
          .includes(:leaveable)
          .order(created_at: :desc)

      else

        Leave
          .select(
            :id,
            :employeename,
            :leaveType,
            :from_date,
            :to_date,
            :reason,
            :status,
            :leaveable_id,
            :leaveable_type,
            :created_at
          )
          .where(
            leaveable_type: "User",
            leaveable_id: current_user.id
          )
          .includes(:leaveable)
          .order(created_at: :desc)

      end
    end

    # ----------------------------------------
    # EMPLOYEE LEAVES
    # ----------------------------------------

    def employee_leaves
      Leave
        .select(
          :id,
          :employeename,
          :leaveType,
          :from_date,
          :to_date,
          :reason,
          :status,
          :leaveable_id,
          :leaveable_type,
          :created_at
        )
        .where(
          leaveable_type: "User",
          leaveable_id: current_user.id
        )
        .includes(:leaveable)
        .order(created_at: :desc)
    end

    # ----------------------------------------
    # COMPANY LEAVES
    # ----------------------------------------

    def company_leaves(company_id, applied_by)
      role =
        if applied_by == "employee"
          :employee
        else
          :hr
        end

      Leave
        .select(
          :id,
          :employeename,
          :leaveType,
          :from_date,
          :to_date,
          :reason,
          :status,
          :leaveable_id,
          :leaveable_type,
          :created_at
        )
        .joins(
          "INNER JOIN users ON users.id = leaves.leaveable_id"
        )
        .where(
          leaveable_type: "User",
          users: {
            company_id: company_id,
            role: User.roles[role]
          }
        )
        .includes(:leaveable)
        .order(created_at: :desc)
    end

    # ----------------------------------------
    # STRONG PARAMETERS
    # ----------------------------------------

    def leave_params
      params.require(:leave).permit(
        :employeename,
        :leaveType,
        :from_date,
        :to_date,
        :reason,
        :status,
        :profileImage
      )
    end
  end
end