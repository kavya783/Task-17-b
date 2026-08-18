class UserService

  def self.create(params, current_user, current_company)
    user = User.new(params)

    if user.role == "hr"
      user.company_id = current_company&.id
    elsif user.role == "employee"
      user.company_id = current_user&.company_id
      user.hr_id = current_user&.id
    end

    if user.save
      Rails.cache.delete("company_#{user.company_id}_hrs") if user.role == "hr"
      user
    else
      raise ActiveRecord::RecordInvalid, user
    end
  end

end