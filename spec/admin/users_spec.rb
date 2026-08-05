require "rails_helper"

RSpec.describe "ActiveAdmin Users", type: :request do
  let!(:admin) do
    AdminUser.create!(
      email: "admin@test.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  before do
    post admin_user_session_path, params: {
      admin_user: {
        email: admin.email,
        password: "password"
      }
    }
  end

  it "opens users index page" do
    create(:user)

    get admin_users_path

    expect(response).to have_http_status(:ok)
  end

  it "opens user show page" do
    user = create(:user)

    get admin_user_path(user)

    expect(response).to have_http_status(:ok)
  end
end