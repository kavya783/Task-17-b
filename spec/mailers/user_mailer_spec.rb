require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  describe "hr_created" do

    it "sends HR created email" do

      hr = create(:user, role: "hr")

      mail = UserMailer.hr_created(hr).deliver_now

      expect(mail.to).to include(hr.email)
      expect(mail.subject).to eq("HR Account Created")

    end

  end


  describe "hr_deleted" do

    it "sends HR deleted email" do

      mail = UserMailer.hr_deleted(
        "hr@test.com",
        "HR User"
      ).deliver_now

      expect(mail.to).to include("hr@test.com")
      expect(mail.subject).to eq("HR Account Deleted")

    end

  end


  describe "leave_notification" do

    it "sends leave application email to HR" do

      hr = create(
        :user,
        role: "hr"
      )

      leave = create(:leave)

      mail = UserMailer.leave_notification(
        hr,
        leave
      ).deliver_now


      expect(mail.to).to include(hr.email)
      expect(mail.subject).to eq("New Leave Application")

    end

  end


  describe "leave_status_notification" do

    it "sends leave status email to employee" do

      employee = create(
        :user,
        role: "employee"
      )

      leave = create(
        :leave,
        status: "approved"
      )


      mail = UserMailer.leave_status_notification(
        employee,
        leave
      ).deliver_now


      expect(mail.to).to include(employee.email)

      expect(mail.subject)
        .to eq("Leave Approved")

    end

  end

end