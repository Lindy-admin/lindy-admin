def login(user, password)
  login_as(user, :scope => :user)
end
