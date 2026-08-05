require "rails_helper"

RSpec.describe WelcomeNotificationJob, type: :job do

  before do
    allow(FirebaseNotificationService)
      .to receive(:send_notification)
  end


  it "creates company welcome notification and sends push notification" do

    company = create(:company)

    create(
      :device_token,
      company: company,
      token: "company_token"
    )

    WelcomeNotificationJob
      .perform_now(company.id, "company")


    notification = Notification.find_by(
      company_id: company.id,
      notification_type: "welcome"
    )


    expect(notification).to be_present

    expect(
      FirebaseNotificationService
    ).to have_received(:send_notification)
      .with(
        "company_token",
        "Welcome",
        "Welcome #{company.name} to WorkSphere Portal"
      )

  end



  it "creates hr welcome notification and sends push notification" do

    user = create(
      :user,
      role: "hr"
    )


    create(
      :device_token,
      user: user,
      token: "hr_token"
    )


    WelcomeNotificationJob
      .perform_now(user.id, "hr")


    notification = Notification.find_by(
      user_id: user.id,
      notification_type: "welcome"
    )


    expect(notification).to be_present


    expect(
      FirebaseNotificationService
    ).to have_received(:send_notification)
      .with(
        "hr_token",
        "Welcome",
        "Welcome #{user.name} to WorkSphere Portal"
      )

  end



  it "creates employee welcome notification without device token" do

    user = create(
      :user,
      role: "employee"
    )


    WelcomeNotificationJob
      .perform_now(user.id, "employee")


    notification = Notification.find_by(
      user_id: user.id,
      notification_type: "welcome"
    )


    expect(notification).to be_present


    expect(
      FirebaseNotificationService
    ).not_to have_received(:send_notification)

  end



  it "does nothing for invalid type" do

    expect {

      WelcomeNotificationJob
        .perform_now(1, "admin")

    }.not_to raise_error

  end


end