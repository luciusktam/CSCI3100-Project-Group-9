Given("the user is on the homepage") do
  visit root_path
  expect(page).to have_css('.navbar')
end

Then("the user should see the app logo {string}") do |logo_text|
  expect(page).to have_css('.logo', text: logo_text)
end

Then("the user should see navigation links for:") do |table|
  links = table.raw.flatten
  within('.nav-links') do
    links.each do |link|
      expect(page).to have_link(link)
    end
  end
end

Then("the user should see a login button in the top right corner") do
  expect(page).to have_link('Login')
end

When("the user clicks the {string} page button") do |button_name|
  within('.nav-links') do
    click_link button_name
  end
end

Then("the user should be redirected to the community page") do
  expect(page).to have_current_path(community_path)
end

Then("the user should be redirected to the chat page") do
  expect(page).to have_current_path(chat_path)
end

Then("the user should be redirected to the sell page") do
  expect(page).to have_current_path(sell_path)
end

Then("the user should be redirected to the profile page") do
  expect(page).to have_current_path(profile_path)
end

When("the user clicks the login button") do
  within('.right-corner') do
    click_link 'Login'
  end
end

Then("the user should be redirected to the login page") do
  expect(page).to have_current_path(login_path)
end