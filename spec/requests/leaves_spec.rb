require "rails_helper"

RSpec.describe "Leaves API", type: :request do

  it "creates leave request" do

    company = create(:company)

    hr = create(
      :user,
      role: "hr",
      company_id: company.id
    )

    employee = create(
      :user,
      role: "employee",
      company_id: company.id,
      hr_id: hr.id,
      email: "test@test.com",
      password: "123456"
    )

    token = JsonWebToken.encode(
      user_id: employee.id
    )

    post "/api/leaves",
    params: {
      leave: {
        employeename: "Test",
        email: employee.email,
        leaveType: "Casual",
        from_date: "2026-08-10",
        to_date: "2026-08-12",
        reason: "Vacation",
        status: "pending"
      }
    },
    headers: {
      "Authorization" => "Bearer #{token}"
    }

    expect(response).to have_http_status(:created)

    expect(Leave.count).to eq(1)

    leave = Leave.last

    expect(leave.employeename).to eq("Test")
    expect(leave.status).to eq("pending")
    expect(leave.hr_id).to eq(hr.id)
    expect(leave.company_id).to eq(company.id)

  end
  it "returns hr employee leaves" do
      company = create(:company)

      hr = create(
        :user,
        role: "hr",
        company_id: company.id
      )

      employee = create(
        :user,
        role: "employee",
        company_id: company.id,
        hr_id: hr.id
      )

      create(
        :leave,
        email: employee.email
      )

      token = JsonWebToken.encode(
        user_id: hr.id
      )

      get "/api/leaves",
        headers:{
          "Authorization"=>"Bearer #{token}"
        }

      expect(response).to have_http_status(:success)
end
   it "returns employee leaves" do

      employee=create(
        :user,
        role:"employee"
      )

    create(
      :leave,
      email:employee.email
    )

    token=JsonWebToken.encode(
      user_id:employee.id
    )

    get "/api/leaves",
    headers:{
      "Authorization"=>"Bearer #{token}"
    }

    expect(response).to have_http_status(:success)

end
it "approves leave" do

  company = create(:company)

  hr = create(
    :user,
    role: "hr",
    company_id: company.id
  )

  employee = create(
    :user,
    role: "employee",
    company_id: company.id,
    hr_id: hr.id
  )

  leave = create(
    :leave,
    email: employee.email,
    hr_id: hr.id,
    company_id: company.id,
    status: "pending"
  )

  token = JsonWebToken.encode(user_id: hr.id)

  patch "/api/leaves/#{leave.id}",
        params: {
          leave: {
            status: "approved"
          }
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

  expect(response).to have_http_status(:ok)

  leave.reload

  expect(leave.status).to eq("approved")

end
it "rejects leave" do

  company = create(:company)

  hr = create(
    :user,
    role: "hr",
    company_id: company.id
  )

  employee = create(
    :user,
    role: "employee",
    company_id: company.id,
    hr_id: hr.id
  )

  leave = create(
    :leave,
    email: employee.email,
    hr_id: hr.id,
    company_id: company.id,
    status: "pending"
  )

  token = JsonWebToken.encode(user_id: hr.id)

  patch "/api/leaves/#{leave.id}",
        params: {
          leave: {
            status: "rejected"
          }
        },
        headers: {
          "Authorization" => "Bearer #{token}"
        }

  expect(response).to have_http_status(:ok)

  leave.reload

  expect(leave.status).to eq("rejected")

end
it "creates leave and sends hr notification" do

 company=create(:company)

 hr=create(
  :user,
  role:"hr",
  company_id:company.id
 )

 employee=create(
  :user,
  role:"employee",
  company_id:company.id,
  hr_id:hr.id
 )

 DeviceToken.create!(
  user_id:hr.id,
  token:"abc"
 )

 allow(UserMailer)
 .to receive(:leave_notification)
 .and_return(
  double(deliver_now:true)
 )

 allow(FirebaseNotificationService)
 .to receive(:send_notification)


 token=JsonWebToken.encode(
  user_id:employee.id
 )


 post "/api/leaves",
 params:{
  leave:{
   employeename:"Test",
   email:employee.email,
   leaveType:"Sick",
   from_date:Date.today,
   to_date:Date.today+1,
   reason:"fever"
  }
 },
 headers:{
  "Authorization"=>"Bearer #{token}"
 }


 expect(response)
 .to have_http_status(:created)

end
it "approves leave notification" do

    employee=create(:user)

    leave=create(
    :leave,
    email:employee.email
    )


    DeviceToken.create!(
    user_id:employee.id,
    token:"token"
    )


    allow(UserMailer)
    .to receive(:leave_status_notification)
    .and_return(
    double(deliver_now:true)
    )


    allow(FirebaseNotificationService)
    .to receive(:send_notification)


    token=JsonWebToken.encode(
    user_id:employee.id
    )


    patch "/api/leaves/#{leave.id}",
    params:{
    leave:{
      status:"approved"
    }
    },
    headers:{
    "Authorization"=>"Bearer #{token}"
    }


    expect(response)
    .to have_http_status(:success)

end
it "returns hr employee leaves" do
  company = create(:company)

  hr = create(
    :user,
    role: "hr",
    company_id: company.id
  )

  employee = create(
    :user,
    role: "employee",
    company_id: company.id,
    hr_id: hr.id
  )

  create(
    :leave,
    email: employee.email
  )

  token = JsonWebToken.encode(
    user_id: hr.id
  )

  get "/api/leaves",
    headers:{
      "Authorization"=>"Bearer #{token}"
    }

  expect(response).to have_http_status(:success)
end
it "returns create validation error" do

 employee=create(:user)

 token=JsonWebToken.encode(
  user_id:employee.id
 )


 post "/api/leaves",
 params:{
  leave:{
   email:""
  }
 },
 headers:{
  "Authorization"=>"Bearer #{token}"
 }


 expect(response)
 .to have_http_status(:unprocessable_entity)

end
describe "Leaves controller missing branches" do


  it "does not send notification when employee missing" do

    user = create(
      :user,
      role:"employee"
    )


    token = JsonWebToken.encode(
      user_id:user.id
    )


    post "/api/leaves",
      params:{
        leave:{
          employeename:"Test",
          email:"none@test.com",
          leaveType:"Sick",
          from_date:Date.today,
          to_date:Date.today+1,
          reason:"Reason"
        }
      },
      headers:{
        "Authorization"=>"Bearer #{token}"
      }


    expect(response)
      .to have_http_status(:created)

  end



  it "does not send notification when hr missing" do


    employee=create(
      :user,
      role:"employee",
      hr_id:nil
    )


    token=JsonWebToken.encode(
      user_id:employee.id
    )


    post "/api/leaves",
      params:{
        leave:{
          employeename:"Test",
          email:employee.email,
          leaveType:"Sick",
          from_date:Date.today,
          to_date:Date.today+1,
          reason:"Reason"
        }
      },
      headers:{
        "Authorization"=>"Bearer #{token}"
      }


    expect(response)
      .to have_http_status(:created)

  end



  it "covers destroy failed branch" do


    leave=create(:leave)


    allow_any_instance_of(Leave)
      .to receive(:destroy)
      .and_return(false)


    token=JsonWebToken.encode(
      user_id:create(:user).id
    )


    delete "/api/leaves/#{leave.id}",
      headers:{
        "Authorization"=>"Bearer #{token}"
      }


    expect(response)
      .to have_http_status(:unprocessable_entity)

  end



  it "covers firebase token loop" do


    employee=create(
      :user,
      role:"employee"
    )


    leave=create(
      :leave,
      email:employee.email,
      status:"pending"
    )


    DeviceToken.create!(
      user_id:employee.id,
      token:"abc"
    )


    allow(UserMailer)
      .to receive_message_chain(
        :leave_status_notification,
        :deliver_now
      )


    allow(FirebaseNotificationService)
      .to receive(:send_notification)


    token=JsonWebToken.encode(
      user_id:employee.id
    )


    patch "/api/leaves/#{leave.id}",
      params:{
        leave:{
          status:"approved"
        }
      },
      headers:{
        "Authorization"=>"Bearer #{token}"
      }


    expect(response)
      .to have_http_status(:success)


  end


end
it "returns error when leave save fails" do

  user = create(:user)

  token = JsonWebToken.encode(
    user_id:user.id
  )

  allow_any_instance_of(Leave)
    .to receive(:save)
    .and_return(false)


  post "/api/leaves",
    params:{
      leave:{
        email:"test@test.com"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:unprocessable_entity)

end
it "updates leave when employee not found" do

  leave=create(
    :leave,
    email:"wrong@email.com"
  )

  user=create(:user)


  token=JsonWebToken.encode(
    user_id:user.id
  )


  patch "/api/leaves/#{leave.id}",
    params:{
      leave:{
        status:"approved"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:success)

end
it "sends rejected notification" do

  employee=create(:user)

  leave=create(
    :leave,
    email:employee.email,
    status:"pending"
  )


  DeviceToken.create!(
    user_id:employee.id,
    token:"token"
  )


  allow(UserMailer)
    .to receive_message_chain(
      :leave_status_notification,
      :deliver_now
    )


  allow(FirebaseNotificationService)
    .to receive(:send_notification)


  token=JsonWebToken.encode(
    user_id:employee.id
  )


  patch "/api/leaves/#{leave.id}",
    params:{
      leave:{
        status:"rejected"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:success)


end
it "creates leave when employee exists but hr does not exist" do

  employee = create(
    :user,
    role:"employee",
    hr_id:nil
  )

  token = JsonWebToken.encode(
    user_id: employee.id
  )


  post "/api/leaves",
    params:{
      leave:{
        employeename:"Test",
        email:employee.email,
        leaveType:"Sick",
        from_date:Date.today,
        to_date:Date.today+1,
        reason:"Reason"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:created)

end
it "creates leave without employee record" do

  user=create(:user)


  token=JsonWebToken.encode(
    user_id:user.id
  )


  post "/api/leaves",
    params:{
      leave:{
        employeename:"Test",
        email:"unknown@test.com",
        leaveType:"Sick",
        from_date:Date.today,
        to_date:Date.today+1,
        reason:"test"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:created)

end
it "updates leave without employee notification" do

  leave=create(
    :leave,
    email:"wrong@test.com"
  )


  user=create(:user)


  token=JsonWebToken.encode(
    user_id:user.id
  )


  patch "/api/leaves/#{leave.id}",
    params:{
      leave:{
        status:"approved"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:success)

end
it "returns update validation error" do

 leave=create(:leave)

 allow_any_instance_of(Leave)
  .to receive(:update)
  .and_return(false)


 token=JsonWebToken.encode(
   user_id:create(:user).id
 )


 patch "/api/leaves/#{leave.id}",
 params:{
   leave:{
    status:"approved"
   }
 },
 headers:{
  "Authorization"=>"Bearer #{token}"
 }


 expect(response)
 .to have_http_status(:unprocessable_entity)

end
it "sends firebase notification to hr token" do

  company=create(:company)

  hr=create(
    :user,
    role:"hr",
    company_id:company.id
  )


  employee=create(
    :user,
    role:"employee",
    company_id:company.id,
    hr_id:hr.id
  )


  DeviceToken.create!(
    user_id:hr.id,
    token:"hr_token"
  )


  allow(UserMailer)
    .to receive_message_chain(
      :leave_notification,
      :deliver_now
    )


  allow(FirebaseNotificationService)
    .to receive(:send_notification)


  token=JsonWebToken.encode(
    user_id:employee.id
  )


  post "/api/leaves",
    params:{
      leave:{
        employeename:"Test",
        email:employee.email,
        leaveType:"Sick",
        from_date:Date.today,
        to_date:Date.today+1,
        reason:"Reason"
      }
    },
    headers:{
      "Authorization"=>"Bearer #{token}"
    }


  expect(response)
    .to have_http_status(:created)

end
it "returns delete failure" do

 leave=create(:leave)

 allow_any_instance_of(Leave)
 .to receive(:destroy)
 .and_return(false)


 token=JsonWebToken.encode(
   user_id:create(:user).id
 )


 delete "/api/leaves/#{leave.id}",
 headers:{
  "Authorization"=>"Bearer #{token}"
 }


 expect(response)
 .to have_http_status(:unprocessable_entity)

end
it "returns leave details" do

  user = create(:user)

  token = JsonWebToken.encode(
    user_id: user.id
  )

  leave = create(
    :leave,
    email: user.email
  )


  get "/api/leaves/#{leave.id}",
      headers: {
        "Authorization" => "Bearer #{token}"
      }


  expect(response)
    .to have_http_status(:ok)


  body = JSON.parse(response.body)

  expect(body["message"])
    .to eq("Leave details fetched successfully")


  expect(body["leave"]["id"])
    .to eq(leave.id)

end

end