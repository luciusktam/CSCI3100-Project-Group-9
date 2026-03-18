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

Given("the product grid displays multiple items") do
  expect(page).to have_css('.listings-grid, .product-grid, [class*="grid"]')
end

When("the user clicks on the product card for {string}") do |product_name|
  within('.listings-grid, .product-grid, [class*="grid"]') do
    click_link product_name
  end
end

Then("the user should be redirected to that product's detail page") do
  expect(page).to have_current_path(%r{/listings/\d+}, ignore_query: true)
end

Then("they should see the full details of {string}") do |product_name|
  expect(page).to have_content(product_name)
  expect(page).to have_css('h1, h2', text: product_name)
end
When("the user is logged in as {string} with password {string}") do |email, password|
  visit login_path
  fill_in "CUHK Email", with: email
  fill_in "Password", with: password
  click_button "Login"
  expect(page).to have_current_path(root_path)
end

Given("there are listings in the product grid") do
  Listing.create!(title: "Film Camera", price: 299, location: "CUHK", category: "Electronics")
  Listing.create!(title: "Leather Sofa", price: 450, location: "Sha Tin", category: "Furniture")
  Listing.create!(title: "Jacket", price: 89, location: "Kowloon Tong", category: "Fashion")
  visit root_path
  expect(page).to have_css('.product-grid')
  expect(page).to have_link("Film Camera")
end
