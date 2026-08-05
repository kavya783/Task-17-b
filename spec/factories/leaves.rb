FactoryBot.define do
  factory :leave do
    employeename { "Test Employee" }
    email { "employee@test.com" }
    leaveType { "Casual" }
    from_date { Date.today }
    to_date { Date.today + 2.days }
    reason { "Vacation" }
    status { "pending" }
    hr_id { 1 }
    company_id { 1 }
  end
end