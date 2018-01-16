def login(user)
  visit new_user_session_path
  fill_in "user_email", :with => user.email
  fill_in "user_password", :with => password
  click_button "Log in"
  expect(page).to have_current_path(user_root_path)
end
