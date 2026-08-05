require "rails_helper"

RSpec.describe "Hrs API", type: :request do


  it "returns HR list" do

    company = create(:company)

    hr = create(
      :user,
      role: "hr",
      company_id: company.id
    )

    token = JsonWebToken.encode(
      company_id: company.id
    )


    get "/api/hrs",
        headers: {
          "Authorization" => token
        }


    expect(response).to have_http_status(:ok)

  end



  it "creates HR successfully" do

    company = create(:company)

    token = JsonWebToken.encode(
      company_id: company.id
    )


    allow(UserMailer)
      .to receive_message_chain(:hr_created, :deliver_now)


    post "/api/hrs",
         params: {
           name: "New HR",
           email: "hr@test.com",
           password: "password",
           address: "Hyderabad"
         },
         headers: {
           "Authorization" => token
         }


    expect(response)
      .to have_http_status(:created)


    expect(response.parsed_body["message"])
      .to eq("HR added successfully")

  end



  it "shows HR details" do

    company = create(:company)

    hr = create(
      :user,
      role: "hr",
      company_id: company.id
    )


    token = JsonWebToken.encode(
      company_id: company.id
    )


    get "/api/hrs/#{hr.id}",
        headers: {
          "Authorization" => token
        }


    expect(response)
      .to have_http_status(:ok)

  end



  it "updates HR successfully" do

    company = create(:company)

    hr = create(
      :user,
      role: "hr",
      company_id: company.id
    )


    token = JsonWebToken.encode(
      company_id: company.id
    )


    put "/api/hrs/#{hr.id}",
        params: {
          name: "Updated HR"
        },
        headers: {
          "Authorization" => token
        }


    expect(response)
      .to have_http_status(:ok)

  end



  it "deletes HR successfully" do

    company = create(:company)

    hr = create(
      :user,
      role: "hr",
      company_id: company.id
    )


    token = JsonWebToken.encode(
      company_id: company.id
    )


    allow(UserMailer)
      .to receive_message_chain(:hr_deleted, :deliver_now)


    delete "/api/hrs/#{hr.id}",
           headers: {
             "Authorization" => token
           }


    expect(response)5
      .to have_http_status(:ok)

  end



  it "returns HR not found" do

    company = create(:company)

    token = JsonWebToken.encode(
      company_id: company.id
    )


    get "/api/hrs/9999",
        headers: {
          "Authorization" => token
        }


    expect(response)
      .to have_http_status(:not_found)

  end


end