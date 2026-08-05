require "rails_helper"

RSpec.describe FirebaseNotificationService do

  let(:device_token) { "test_token" }

  before do
    allow(ENV)
      .to receive(:[])
      .with("FIREBASE_PROJECT_ID")
      .and_return("test_project")
  end


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
      code: "200"
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
        "Test Title",
        "Test Body"
      )

    }.not_to raise_error

  end


  it "handles firebase failure response" do

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

    }.not_to raise_error

  end

end