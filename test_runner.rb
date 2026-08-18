begin
  # Clear existing test data
  Leave.delete_all
  User.where(email: ['hr@gmail.com', 'test_hr@gmail.com']).delete_all
  Company.where(email: 'company@gmail.com').delete_all

  # 1. Create company
  company = Company.create!(
    email: 'company@gmail.com',
    name: 'Test Company',
    password: 'Password@123',
    address: '123 Test St'
  )

  # 2. Create HR user belonging to company
  hr = User.create!(
    email: 'hr@gmail.com',
    name: 'HR Name',
    password: 'Password@123',
    role: 'hr',
    company: company
  )

  # 3. Create Leave record associated with HR
  leave = Leave.create!(
    leaveable: hr,
    company_id: company.id,
    employeename: 'HR Name',
    leaveType: 'Casual',
    from_date: Date.today,
    to_date: Date.today,
    reason: 'Vacation',
    status: 'pending'
  )

  # 4. Simulate the API controller leaves query and rendering
  hr_ids = User.where(company_id: company.id, role: 'hr').pluck(:id)
  leaves = Leave.where(leaveable_type: 'User', leaveable_id: hr_ids)

  res = leaves.map { |l|
    user = l.leaveable
    {
      id: l.id,
      employeename: l.employeename || user&.name,
      email: user&.email,
      leaveType: l.leaveType,
      from_date: l.from_date,
      to_date: l.to_date,
      reason: l.reason,
      status: (l.status.presence || 'pending').downcase,
      profile_image_url: l.profileImage
    }
  }

  puts "RESULT: #{res.inspect}"
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace.first(5)
end
