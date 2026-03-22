
include ActionView::Helpers::NumberHelper # for number_with_precision

Given("I create {int} test listings") do |count|
  create_test_listings(count)
end

Then("I should see the 8 most recent listings") do
  latest_listings = Listing.order(created_at: :desc).limit(8)

  latest_listings.each do |listing|
    expect(page).to have_content(listing.title)
    expect(page).to have_content("$#{number_with_precision(listing.price, precision: 2)}")
  end
  expect(page).to have_css(".listing-card", count: latest_listings.count)
end

Then("I should see listing titles, prices, and images") do
  expect(page).to have_css(".listing-card-title")
  expect(page).to have_css(".listing-card-price", minimum: 1)
  expect(page).to have_css(".listing-card-image, .listing-image-placeholder", minimum: 1)
end

When("I click 'view all'") do
  click_link "view all"
end

Then("I should be on the listings index page") do
  expect(page).to have_current_path(listings_path)
end

Then("I should see pagination if there are more than 20 listings") do
  if Listing.count > 20
    expect(page).to have_css(".pagination")
  else
    expect(page).not_to have_css(".pagination")
  end
end

Then("I should see No listings yet") do
  expect(page).to have_content("No listings yet")
  expect(page).to have_content("Be the first to list an item!")
  expect(page).to have_link("Create a Listing")
end


def create_test_user
  @user = User.create!(
    username: "testuser",
    email: "test@link.cuhk.edu.hk",
    password: "password123",
    password_confirmation: "password123",
    email_verified: true,
    verified_at: Time.current
  )
end

def create_test_listings(count = 8)
  user = create_test_user
  test_image_path = Rails.root.join("spec/fixtures/files/test_image.jpg")

  count.times do |i|
    Listing.create!(
      title: "Test Item #{i + 1}",
      description: "This is a test description for item #{i + 1}",
      price: 10.00 + i,
      category: [ "Electronics", "Books", "Furniture", "Clothing" ].sample,
      condition: [ "New", "Like New", "Good" ].sample,
      location: "Campus",
      user: user,
      created_at: Time.now - i.hours,
      photos: [ fixture_file_upload(test_image_path, "image/jpeg") ]
    )
    listing = Listing.last
    listing.save!
  end
end
