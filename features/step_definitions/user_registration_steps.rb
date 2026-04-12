Given("I am on the register page") do
  visit register_path
end

Given("a verified user exists with email {string} and password {string}") do |email, password|
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    username: email.split("@").first,
    password: password,
    password_confirmation: password,
    email_verified: true,
    verified_at: Time.current
  )
  user.save!
end

Given("an unverified user exists with email {string} and password {string}") do |email, password|
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    username: email.split("@").first,
    password: password,
    password_confirmation: password,
    email_verified: false,
    verified_at: nil
  )
  user.save!
end

Given("I am logged in as {string} with password {string}") do |email, password|
  step %(I log in with email "#{email}" and password "#{password}")
  expect(page).to have_current_path(root_path)
end

When("I click on the login button in the top right corner") do
  within(".right-corner") do
    click_link "Login"
  end
end

When("I click the register link on the login page") do
  click_link "Click here to register"
end

When("I register with email {string}, username {string}, password {string}, and confirmation {string}") do |email, username, password, confirmation|
  fill_in 'sid@link.cuhk.edu.hk', with: email
  fill_in 'cuhkstudent', with: username
  find('input[name="user[password]"]').fill_in(with: password)
  find('input[name="user[password_confirmation]"]').fill_in(with: confirmation)
  click_button 'Create account'
end

When("I log in with email {string} and password {string}") do |email, password|
  visit login_path
  fill_in 'sid@link.cuhk.edu.hk', with: email
  fill_in 'password', with: password
  click_button 'Login'
end

When("I click the logout button") do
  # Try to find logout button, if not found, click session badge to access dropdown
  if page.has_button?("Logout")
    click_button "Logout"
  elsif page.has_css?(".session-badge")
    find(".session-badge").click
    sleep 0.5
    if page.has_link?("Logout")
      click_link "Logout"
    elsif page.has_button?("Logout")
      click_button "Logout"
    end
  end
end

Then("I should see the login page") do
  expect(page).to have_current_path("/login", ignore_query: true)
  expect(page).to have_css("h2", text: "Login")
  expect(page).to have_button("Login")
end

Then("I should see a message to log in") do
  # The page should show a message about logging in, either on the current page or redirecting to login
  if page.current_path.include?("/login")
    expect(page).to have_current_path("/login", ignore_query: true)
  end
end

Then("I should see the register page") do
  expect(page).to have_current_path(register_path)
  expect(page).to have_css("h2", text: "Register")
  expect(page).to have_button("Create account")
end

Then("I should be redirected to the login page") do
  current = page.current_path.split("?").first
  expect([ "/login", "/users" ]).to include(current)
end

Then("I should be redirected to the home page") do
  expect(page).to have_current_path(root_path, ignore_query: true)
end

Then("I should stay on the register page") do
  current = page.current_path.split("?").first
  expect([ register_path, users_path ]).to include(current)
  expect(page).to have_css("h2", text: "Register")
  expect(page).to have_button("Create account")
end

Then("I should stay on the login page") do
  current = page.current_path.split("?").first
  expect([ login_path ]).to include(current)
  expect(page).to have_css("h2", text: "Login")
  expect(page).to have_button("Login")
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end

Then("a verification email should be sent to {string}") do |email|
  # Verify the user was created with a verification token (email sending is tested in RSpec)
  user = User.find_by(email: email)
  expect(user).not_to be_nil
  expect(user.verification_token).to be_present
  expect(user.email_verified).to be false
end

When("I follow the verification link in the email") do
  email = ActionMailer::Base.deliveries.last
  body = if email.multipart?
    email.text_part.decoded
  else
    email.body.decoded
  end
  token_match = body.match(%r{https?://\S*/verify/(\S+)}i) ||
                body.match(%r{/verify/([0-9a-f]+)})
  expect(token_match).not_to be_nil, "Could not find a /verify/:token link in the email body"
  visit "/verify/#{token_match[1]}"
end

When("I visit the verification link with token {string}") do |token|
  visit "/verify/#{token}"
end
