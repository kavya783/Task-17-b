class UserMailer < ApplicationMailer
 default from: "kavya.actimize@gmail.com"



  # HR Added Mail
  def hr_created(hr)
     Rails.logger.info "MAIL STARTED TO #{hr.email}"
    @hr = hr

    mail(
      to: @hr.email,
      subject: "HR Account Created"
    )
  end


  # HR Deleted Mail
 def hr_deleted(hr_email, hr_name)

    Rails.logger.info "DELETE MAIL STARTED TO #{hr_email}"

    @hr_name = hr_name

    mail(
      to: hr_email,
      subject: "Your HR Account Has Been Deleted"
    )
  end



  # Leave Applied Mail To HR
  def leave_notification(hr, leave)
    @hr = hr
    @leave = leave

    mail(
      to: @hr.email,
      subject: "New Leave Application"
    )
  end


  # Leave Status Mail To Employee
  def leave_status_notification(employee, leave)
    @employee = employee
    @leave = leave

    mail(
      to: @employee.email,
      subject: "Leave #{@leave.status.capitalize}"
    )
  end

end