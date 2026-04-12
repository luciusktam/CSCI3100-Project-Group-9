Given("I am on the home page") do
  visit root_path
end

Then("I should see the app logo {string}") do |logo_text|
  expect(page).to have_css('.logo', text: logo_text)
end

Then("I should see navigation links for:") do |table|
  links = table.raw.flatten
  links.each do |link|
    case link
    when "Community"
      expect(page).to have_css(".nav-community-btn")
    when "Chat"
      expect(page).to have_css(".nav-chat-btn")
    when "Sell"
      # Sell is now "Post Items" in section-header
      expect(page).to have_css(".section-actions")
    when "Profile"
      expect(page).to have_css(".session-badge")
    end
  end
end

Then("I should see a login button in the top right corner") do
  expect(page).to have_css('.login-btn')
end

Then("I should see the community button") do
  expect(page).to have_css('.nav-community-btn')
end

Then("I should see my username in the session badge") do
  expect(page).to have_css('.session-badge')
end

When("I click the {string} page button") do |button_name|
  case button_name
  when "Community"
    # Click the community nav button
    find(".nav-community-btn").click
  when "Chat"
    # Click the chat nav button (it's an icon button with aria-label)
    find(".nav-chat-btn").click
  when "Sell"
    click_link "Post Items", match: :first
  when "Profile"
    # Profile is in session-badge
    find(".session-badge").click
  else
    within('.nav-links') do
      click_link button_name
    end
  end
end

Then("I should be redirected to the community page") do
  expect(page).to have_current_path(community_path)
end

Then("I should be redirected to the chat page") do
  expect(page).to have_current_path(chat_path)
end

Then("I should be redirected to the sell page") do
  expect(page).to have_current_path(sell_path)
end

Then("I should be redirected to the profile page") do
  expect(page).to have_current_path(profile_path)
end

When("I click the login button") do
  within('.right-corner') do
    click_link 'Login', match: :first
  end
end

Given("the product grid displays multiple items") do
  expect(page).to have_css('.listings-grid, .product-grid, [class*="grid"]')
end

When("I click on the product card for {string}") do |product_name|
  within('.listings-grid, .product-grid, [class*="grid"]') do
    click_link product_name
  end
end

Then("I should be redirected to that product's detail page") do
  expect(page).to have_current_path(%r{/listings/\d+}, ignore_query: true)
end

Then("I should see the full details of {string}") do |product_name|
  expect(page).to have_content(product_name)
  expect(page).to have_css('h1, h2', text: product_name)
end

Given("there are listings in the product grid") do
  Listing.create!(title: "Film Camera", price: 299, location: "CUHK", category: "Electronics")
  Listing.create!(title: "Leather Sofa", price: 450, location: "Sha Tin", category: "Furniture")
  Listing.create!(title: "Jacket", price: 89, location: "Kowloon Tong", category: "Fashion")
  visit root_path
  expect(page).to have_css('.listings-grid')
  expect(page).to have_link("Film Camera")
end
