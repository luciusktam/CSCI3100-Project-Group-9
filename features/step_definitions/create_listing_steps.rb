Given("I am on the sell page") do
  visit sell_path
end

Given("I am on the listings page") do
  visit listings_path
end

When("I click on the sell button") do
    click_link "Sell"
end

Then("I should see 'Please log in before listing items for sale'") do
  expect(page).to have_content("Please log in before listing items for sale")
end

Then("I should see the sell page") do
  expect(page).to have_current_path(sell_path)
  expect(page).to have_css("h2", text: "Create a new listing")
  expect(page).to have_field("listing[photos][]", type: 'file')
  expect(page).to have_field("listing[category]")
  expect(page).to have_field("listing[title]")
  expect(page).to have_field("listing[price]")
  expect(page).to have_field("listing[condition]")
  expect(page).to have_field("listing[description]")
  expect(page).to have_button("List it!")
end

When("I fill in all required fields with valid data") do
  fill_in "Listing title", with: "Vintage Camera"
  fill_in "Price", with: "250"
  select "Electronics", from: "Category"
  select "Good", from: "Condition"
  fill_in "Location", with: "Chung Chi College"
  fill_in "Description", with: "A vintage film camera in good condition"
end

When("I upload {int} product photos") do |count|
  files = []

  count.times do |i|
    temp_file = Tempfile.new([ "test_photo_#{i}", '.jpg' ])
    temp_file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00")
    temp_file.rewind
    files << temp_file.path
  end

  attach_file("listing[photos][]", files, make_visible: true)

  sleep 0.5
end

When("I submit the form") do
  click_button "List it!"
end

Then('I should see a success message') do
  expect(page).to have_text('Your item is listed!')
end

Then("I should be on the new listing page") do
  listing = Listing.last
  expect(page).to have_current_path(listing_path(listing))
end

Then("my listing should be visible with all details") do
  listing = Listing.last
  expect(page).to have_content(listing.title)
  expect(page).to have_content("$250.00")
  expect(page).to have_content("Electronics")
  expect(page).to have_content("Good")
  expect(page).to have_content("Chung Chi College")
  expect(page).to have_content("A vintage film camera in good condition")
  expect(page).to have_content("AVAILABLE")
  expect(page).to have_css(".listing-image", count: 2)
end

When("I do not fill in all required fields") do
  select "Good", from: "Condition"
  fill_in "Location", with: "Chung Chi College"
  fill_in "Description", with: "A vintage film camera in good condition"
end

Then("I should see validation error messages") do
  expect(page).to have_content("Title can't be blank")
  expect(page).to have_content("Price can't be blank")
  expect(page).to have_content("Category can't be blank")
end

Then("I should stay on the sell page") do
  expect(page).to have_current_path(sell_path)
  expect(page).to have_css("h2", text: "Create a new listing")
end
