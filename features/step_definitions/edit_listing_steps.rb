
Given("I am logged in as a different user") do
  click_button "Logout"
  @user = User.create!(
    username: "testuser2",
    email: "test2@link.cuhk.edu.hk",
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

When("I visit the edit page for my listing") do
  visit edit_listing_path(@listing)
end

When("I visit the edit page for the listing {string}") do |title|
  listing = Listing.find_by(title: title)
  visit edit_listing_path(listing)
end

When("I fill in the edit form with updated valid data") do
  fill_in "Listing title", with: "iPhone 12 Pro Max"
  fill_in "Price", with: "650"
  select "Like New", from: "Condition"
  select "Reserved", from: "Status"
  fill_in "Location", with: "S.H. Ho College"
  fill_in "Description", with: "Updated: Like new condition iPhone 12 Pro Max"
end

When("I update {int} product photo") do |count|
  files = []

  count.times do |i|
    temp_file = Tempfile.new([ "updated_photo_#{i}", '.jpg' ])
    temp_file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00")
    temp_file.rewind
    files << temp_file.path
  end

  attach_file("listing[photos][]", files, make_visible: true)
  sleep 0.5
end

When("I submit the edit form") do
  click_button "Update listing"
end

When("I remove the title") do
  fill_in "Listing title", with: ""
end

Then("I should see an update success message") do
  expect(page).to have_content("Listing updated successfully！")
end

Then("I should be on the updated listing page") do
  @listing.reload
  expect(page).to have_current_path(listing_path(@listing))
end

Then("my listing should show all updated details") do
  @listing.reload
  expect(page).to have_content("iPhone 12 Pro Max")
  expect(page).to have_content("$650.00")
  expect(page).to have_content("Like New")
  expect(page).to have_content("RESERVED")
  expect(page).to have_content("S.H. Ho College")
  expect(page).to have_content("Updated: Like new condition iPhone 12 Pro Max")
end

Then("I should see validation error messages on the edit page") do
  expect(page).to have_content("Title can't be blank")
  expect(page).to have_css(".error-messages")
end

Then("I should stay on the edit page") do
  expect(page).to have_css("h2", text: "Edit listing")
end

Then("my listing should still have the original title {string}") do |title|
  @listing.reload
  expect(@listing.title).to eq(title)
end

Then("I should see an unauthorized message") do
  expect(page).to have_content("You are not authorized to perform this action")
end

Then("I should be redirected to the listing page") do
  expect(page).to have_current_path(listing_path(@listing))
end
