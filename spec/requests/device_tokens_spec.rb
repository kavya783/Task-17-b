require "rails_helper"

RSpec.describe "Device Tokens API", type: :request do


  describe "POST /api/device_tokens" do


    it "saves device token for user" do

      user = create(:user)

      token = JsonWebToken.encode(
        user_id: user.id
      )

      post "/api/device_tokens",
        params: {
          token: "firebase123"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      expect(
        DeviceToken.last.token
      ).to eq("firebase123")

    end



    it "saves device token for company" do

      company = create(:company)

      token = JsonWebToken.encode(
        company_id: company.id
      )

      post "/api/device_tokens",
        params: {
          token: "company_token_123"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      expect(
        DeviceToken.last.token
      ).to eq("company_token_123")

    end

it "returns unauthorized without user or company" do

  allow_any_instance_of(Api::DeviceTokensController)
    .to receive(:current_user)
    .and_return(nil)

  allow_any_instance_of(Api::DeviceTokensController)
    .to receive(:current_company)
    .and_return(nil)


  post "/api/device_tokens",
       params: {
         token: "test_token"
       },
       headers: {
         "Authorization" => "Bearer test"
       }


  expect(response)
    .to have_http_status(:unauthorized)

end

    it "returns error when token save fails" do

      user = create(:user)

      allow_any_instance_of(DeviceToken)
        .to receive(:save)
        .and_return(false)


      token = JsonWebToken.encode(
        user_id: user.id
      )


      post "/api/device_tokens",
        params: {
          token: "firebase123"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }


      expect(response)
        .to have_http_status(:unprocessable_entity)


      body = JSON.parse(response.body)

      expect(body["errors"]).to be_present

    end


  end

end