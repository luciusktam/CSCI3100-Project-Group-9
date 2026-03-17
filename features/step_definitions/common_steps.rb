
Given("I am not logged in") do
  visit logout_path if page.has_button?('Logout')
end

Given("I am logged in") do
  @user = User.create!(
    username: "testuser",
    email: "test@link.cuhk.edu.hk",
    password: "password123",
    password_confirmation: "password123",
    email_verified: true,
    verified_at: Time.current
  )
  visit login_path
  fill_in "email", with: @user.email
  fill_in "password", with: "password123"
  click_button "Login"
  expect(page).to have_content(@user.username)
end
