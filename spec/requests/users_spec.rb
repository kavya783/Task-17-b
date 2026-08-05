require "rails_helper"

RSpec.describe "Users API", type: :request do

  describe "GET /api/users" do

    it "returns HR list for company" do

      company = create(:company)

      create(:user,
        role: "hr",
        company_id: company.id,
        email: "hr1@test.com"
      )

      create(:user,
        role: "hr",
        company_id: company.id,
        email: "hr2@test.com"
      )

      token = JsonWebToken.encode(
        company_id: company.id
      )

      get "/api/users",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)

      expect(body.length).to eq(2)

    end


    it "returns logged in employee" do

      company = create(:company)

      employee = create(
        :user,
        role: "employee",
        company_id: company.id
      )

      token = JsonWebToken.encode(
        user_id: employee.id
      )

      get "/api/users",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)

      expect(body.length).to eq(1)

    end


    it "returns employees for hr" do

      company = create(:company)

      hr = create(
        :user,
        role: "hr",
        company_id: company.id
      )

      create(
        :user,
        role: "employee",
        company_id: company.id,
        hr_id: hr.id,
        email: "emp1@test.com"
      )

      create(
        :user,
        role: "employee",
        company_id: company.id,
        hr_id: hr.id,
        email: "emp2@test.com"
      )

      token = JsonWebToken.encode(
        user_id: hr.id
      )

      get "/api/users",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)

      expect(body.length).to eq(2)

    end

  end
  describe "GET /api/users" do

      it "returns empty list for unknown user role" do

        user = create(
          :user,
          role: "admin"
        )

        token = JsonWebToken.encode(
          user_id: user.id
        )

        get "/api/users",
          headers: {
            "Authorization" => "Bearer #{token}"
          }

        expect(response).to have_http_status(:success)

        body = JSON.parse(response.body)

        expect(body).to eq([])

      end

end


  describe "GET /api/users/:id" do

    it "returns user details" do

      user = create(:user)

      token = JsonWebToken.encode(
        user_id: user.id
      )

      get "/api/users/#{user.id}",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)

      expect(body["id"]).to eq(user.id)

    end

  end
  describe "GET /api/users/:id" do

    it "returns user with profile image url" do

      user = create(:user)

      user.profile_image.attach(
        io: File.open(
          Rails.root.join("spec/fixtures/files/test.png")
        ),
        filename: "test.png",
        content_type: "image/png"
      )

      token = JsonWebToken.encode(
        user_id: user.id
      )

      get "/api/users/#{user.id}",
        headers:{
          "Authorization"=>"Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      body = JSON.parse(response.body)

      expect(body["profile_image_url"]).not_to be_nil

    end

end


  describe "POST /api/users" do

    it "creates employee" do

      company = create(:company)

      hr = create(
        :user,
        role: "hr",
        company_id: company.id
      )

      token = JsonWebToken.encode(
        user_id: hr.id
      )

      post "/api/users",
        params: {
          name: "New Employee",
          email: "new@test.com",
          password: "123456",
          role: "employee"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:created)

      expect(User.last.role).to eq("employee")

    end


    it "creates HR user" do

      company = create(:company)

      token = JsonWebToken.encode(
        company_id: company.id
      )

      post "/api/users",
        params: {
          name: "New HR",
          email: "hr@test.com",
          password: "123456",
          role: "hr"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:created)

      expect(User.last.role).to eq("hr")

    end
    it "converts role into lowercase" do

  company = create(:company)

  token = JsonWebToken.encode(
    company_id: company.id
  )

  post "/api/users",
    params: {
      name: "Upper HR",
      email: "upperhr@test.com",
      password: "123456",
      role: "HR"
    },
    headers: {
      "Authorization" => "Bearer #{token}"
    }

  expect(response).to have_http_status(:created)

  expect(User.last.role).to eq("hr")

end

  end


  describe "POST /api/save_fcm_token" do

    it "updates fcm token" do

      user = create(:user)

      token = JsonWebToken.encode(
        user_id: user.id
      )

      post "/api/save_fcm_token",
        params: {
          user_id: user.id,
          fcm_token: "firebase123"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      user.reload

      expect(user.fcm_token).to eq("firebase123")

    end

  end
  describe "POST /api/save_fcm_token" do

    it "returns error when fcm token update fails" do

      user = create(:user)

      allow_any_instance_of(User)
        .to receive(:update)
        .and_return(false)

      token = JsonWebToken.encode(
        user_id:user.id
      )

      post "/api/save_fcm_token",
        params:{
          user_id:user.id,
          fcm_token:"firebase123"
        },
        headers:{
          "Authorization"=>"Bearer #{token}"
        }

      expect(response).to have_http_status(:unprocessable_entity)

    end

end
  describe "POST /api/users" do

    it "returns errors when user creation fails" do

      company = create(:company)

      token = JsonWebToken.encode(
        company_id: company.id
      )

      post "/api/users",
        params: {
          name: "",
          email: "",
          password: "",
          role: "hr"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body["errors"]).not_to be_empty

    end

end


  describe "PATCH /api/users/:id" do

    it "updates user" do

      user = create(:user)

      token = JsonWebToken.encode(
        user_id: user.id
      )

      patch "/api/users/#{user.id}",
        params: {
          name: "Updated Name"
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      user.reload

      expect(user.name).to eq("Updated Name")

    end

  end
describe "PATCH /api/users/:id" do

  it "returns errors when update fails" do

    user = create(:user)

    allow_any_instance_of(User)
      .to receive(:update)
      .and_return(false)

    token = JsonWebToken.encode(
      user_id: user.id
    )

    patch "/api/users/#{user.id}",
      params: {
        name: "Updated Name"
      },
      headers: {
        "Authorization" => "Bearer #{token}"
      }

    expect(response).to have_http_status(:unprocessable_entity)

  end

end


  describe "DELETE /api/users/:id" do

    it "deletes user" do

      user = create(:user)

      token = JsonWebToken.encode(
        user_id: user.id
      )

      delete "/api/users/#{user.id}",
        headers: {
          "Authorization" => "Bearer #{token}"
        }

      expect(response).to have_http_status(:success)

      expect(User.exists?(user.id)).to eq(false)

    end

  end
  describe "DELETE /api/users/:id" do

    it "returns error when delete fails" do

      user = create(:user)

      allow_any_instance_of(User)
        .to receive(:destroy)
        .and_return(false)

      token = JsonWebToken.encode(
        user_id: user.id
      )

      delete "/api/users/#{user.id}",
        headers:{
          "Authorization"=>"Bearer #{token}"
        }

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Delete failed")

    end

end
describe "Authentication" do

  it "returns error when token missing" do

    get "/api/users"

    expect(response).to have_http_status(:unauthorized)

    body = JSON.parse(response.body)

    expect(body["error"]).to eq("Token missing")

  end


  it "returns error for invalid token" do

    get "/api/users",
      headers: {
        "Authorization" => "Bearer invalid_token"
      }

    expect(response).to have_http_status(:unauthorized)

    body = JSON.parse(response.body)

    expect(body["error"]).to eq("Unauthorized")

  end


  it "returns error when user not found" do

    token = JsonWebToken.encode(
      user_id: 999999
    )

    get "/api/users",
      headers: {
        "Authorization" => "Bearer #{token}"
      }

    expect(response).to have_http_status(:not_found)

    body = JSON.parse(response.body)

    expect(body["error"]).to eq("User not found")

  end


  it "returns error when company not found" do

    token = JsonWebToken.encode(
      company_id: 999999
    )

    get "/api/users",
      headers: {
        "Authorization" => "Bearer #{token}"
      }

    expect(response).to have_http_status(:not_found)

    body = JSON.parse(response.body)

    expect(body["error"]).to eq("User not found")

  end
  it "returns empty list when no current user or company" do

  allow_any_instance_of(Api::UsersController)
    .to receive(:authenticate_request)
    .and_return(true)

  allow_any_instance_of(Api::UsersController)
    .to receive(:current_user)
    .and_return(nil)

  allow_any_instance_of(Api::UsersController)
    .to receive(:current_company)
    .and_return(nil)


  get "/api/users"


  expect(response)
    .to have_http_status(:success)


  expect(JSON.parse(response.body))
    .to eq([])

end

end

end