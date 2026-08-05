require "rails_helper"

RSpec.describe "Notifications API", type: :request do

  it "returns user notifications" do
    user = create(:user)

    token = JsonWebToken.encode(user_id: user.id)

    create(
      :notification,
      user: user,
      notification_type: "leave"
    )

    get "/api/notifications",
        headers: { "Authorization" => token }

    expect(response).to have_http_status(:ok)
  end


  it "returns company notifications" do
    company = create(:company)

    token = JsonWebToken.encode(company_id: company.id)

    create(
      :notification,
      company: company,
      notification_type: "leave"
    )

    get "/api/notifications",
        headers: { "Authorization" => token }

    expect(response).to have_http_status(:ok)
  end


  it "returns welcome notification" do
    user = create(:user)

    token = JsonWebToken.encode(user_id: user.id)

    create(
      :notification,
      user: user,
      notification_type: "welcome",
      read: false
    )

    get "/api/notifications/welcome",
        headers: { "Authorization" => token }

    expect(response).to have_http_status(:ok)
  end


  it "marks notification as read" do
    user = create(:user)

    token = JsonWebToken.encode(user_id: user.id)

    notification = create(
      :notification,
      user: user,
      read: false
    )

    put "/api/notifications/#{notification.id}/mark_as_read",
        headers: { "Authorization" => token }

    expect(response).to have_http_status(:ok)

    expect(notification.reload.read).to eq(true)
  end


  it "deletes notification" do
    user = create(:user)

    token = JsonWebToken.encode(user_id: user.id)

    notification = create(
      :notification,
      user: user
    )

    delete "/api/notifications/#{notification.id}",
           headers: { "Authorization" => token }

    expect(response).to have_http_status(:ok)

    expect(Notification.exists?(notification.id)).to be false
  end
  it "sends notification successfully" do

  employee = create(
    :user,
    role: "employee",
    fcm_token: "test_token"
  )

  token = JsonWebToken.encode(
    user_id: employee.id
  )

  allow(FirebaseNotificationService)
    .to receive(:send_notification)

  post "/api/notifications",
       params: {
         employee_id: employee.id,
         title: "Test Notification",
         body: "Hello Employee"
       },
       headers: {
         "Authorization" => token
       }

  expect(response).to have_http_status(:ok)

  expect(response.parsed_body["message"])
    .to eq("Notification sent successfully")

  expect(FirebaseNotificationService)
    .to have_received(:send_notification)
    .with(
      "test_token",
      "Test Notification",
      "Hello Employee"
    )

end

end