require "rails_helper"

RSpec.describe FirebaseNotificationService do

  let(:device_token) { "test_token" }

  before do
    allow(ENV)
      .to receive(:[])
      .with("FIREBASE_PROJECT_ID")
      .and_return("test_project")

    allow(File)
      .to receive(:exist?)
      .and_return(true)

    allow(File)
      .to receive(:open)
      .and_return(
        instance_double(File)
      )
  end

  # --------------------------------------------------
  # Successful notification
  # --------------------------------------------------

  it "sends firebase notification successfully" do

    authorizer = instance_double(
      Google::Auth::ServiceAccountCredentials
    )

    allow(Google::Auth::ServiceAccountCredentials)
      .to receive(:make_creds)
      .and_return(authorizer)

    allow(authorizer)
      .to receive(:fetch_access_token!)

    allow(authorizer)
      .to receive(:access_token)
      .and_return("access_token")

    response = instance_double(
      Net::HTTPResponse,
      code: "200",
      body: ""
    )

    http = instance_double(Net::HTTP)

    allow(Net::HTTP)
      .to receive(:new)
      .and_return(http)

    allow(http)
      .to receive(:use_ssl=)

    allow(http)
      .to receive(:request)
      .and_return(response)

    expect(
      FirebaseNotificationService.send_notification(
        device_token,
        "Test Title",
        "Test Body"
      )
    ).to eq(true)

  end

  # --------------------------------------------------
  # Firebase server error
  # --------------------------------------------------

  it "raises error when firebase returns failure response" do

    authorizer = instance_double(
      Google::Auth::ServiceAccountCredentials
    )

    allow(Google::Auth::ServiceAccountCredentials)
      .to receive(:make_creds)
      .and_return(authorizer)

    allow(authorizer)
      .to receive(:fetch_access_token!)

    allow(authorizer)
      .to receive(:access_token)
      .and_return("access_token")

    response = instance_double(
      Net::HTTPResponse,
      code: "500",
      body: "Firebase Error"
    )

    http = instance_double(Net::HTTP)

    allow(Net::HTTP)
      .to receive(:new)
      .and_return(http)

    allow(http)
      .to receive(:use_ssl=)

    allow(http)
      .to receive(:request)
      .and_return(response)

    expect {
      FirebaseNotificationService.send_notification(
        device_token,
        "Title",
        "Body"
      )
    }.to raise_error(
      StandardError,
      /FCM notification failed/
    )

  end

  # --------------------------------------------------
  # UNREGISTERED FCM token
  # --------------------------------------------------

  it "raises unregistered error for invalid firebase token" do

    authorizer = instance_double(
      Google::Auth::ServiceAccountCredentials
    )

    allow(Google::Auth::ServiceAccountCredentials)
      .to receive(:make_creds)
      .and_return(authorizer)

    allow(authorizer)
      .to receive(:fetch_access_token!)

    allow(authorizer)
      .to receive(:access_token)
      .and_return("access_token")

    response = instance_double(
      Net::HTTPResponse,
      code: "404",
      body: {
        error: {
          details: [
            {
              "@type" =>
                "type.googleapis.com/google.firebase.fcm.v1.FcmError",
              "errorCode" => "UNREGISTERED"
            }
          ]
        }
      }.to_json
    )

    http = instance_double(Net::HTTP)

    allow(Net::HTTP)
      .to receive(:new)
      .and_return(http)

    allow(http)
      .to receive(:use_ssl=)

    allow(http)
      .to receive(:request)
      .and_return(response)

    expect {
      FirebaseNotificationService.send_notification(
        device_token,
        "Title",
        "Body"
      )
    }.to raise_error(
      StandardError,
      /UNREGISTERED/
    )

  end

  # --------------------------------------------------
  # Missing token
  # --------------------------------------------------

  it "raises error when device token is missing" do

    expect {
      FirebaseNotificationService.send_notification(
        nil,
        "Title",
        "Body"
      )
    }.to raise_error(
      ArgumentError,
      "FCM device token is missing"
    )

  end

end