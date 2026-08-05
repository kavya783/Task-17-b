require "rails_helper"

RSpec.describe "Auth API", type: :request do

  describe "POST /api/signup" do
    it "creates a new user" do
      post "/api/signup", params: {
        name: "Kavya",
        email: "kavya@test.com",
        password: "password",
        role: "employee"
      }

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      expect(body["message"]).to eq("Signup success")
    end

    it "returns validation errors" do
      post "/api/signup", params: {
        name: "",
        email: "",
        password: "",
        role: ""
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/login" do
    it "logs in a company" do
      company = create(
        :company,
        email: "company@test.com",
        password: "password"
      )

      post "/api/login", params: {
        email: company.email,
        password: "password"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["type"]).to eq("company")
      expect(body["token"]).to be_present
    end

    it "logs in an hr" do
      hr = create(
        :user,
        email: "hr@test.com",
        password: "password",
        role: "hr"
      )

      post "/api/login", params: {
        email: hr.email,
        password: "password"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["role"]).to eq("hr")
    end

    it "logs in an employee" do
      employee = create(
        :user,
        email: "employee@test.com",
        password: "password",
        role: "employee"
      )

      post "/api/login", params: {
        email: employee.email,
        password: "password"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["role"]).to eq("employee")
    end

    it "returns unauthorized for invalid credentials" do
      post "/api/login", params: {
        email: "wrong@test.com",
        password: "wrongpassword"
      }

      expect(response).to have_http_status(:unauthorized)

      body = JSON.parse(response.body)

      expect(body["error"]).to eq("Invalid email or password")
    end
  end
end