Given("the following listings exist:") do |table|
  user = User.create!(
    username: "testuser",
    email: "test@link.cuhk.edu.hk",
    password: "password123",
    email_verified: true
  )

  table.hashes.each do |row|
    listing = Listing.new(
      title: row["title"],
      price: row["price"],
      category: row["category"],
      condition: row["condition"],
      location: row["location"],
      description: row["description"],
      user: user
    )

    file_path = Rails.root.join("features", "support", "fixtures", "test.jpg")
    listing.photos.attach(
      io: File.open(file_path),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )

    listing.save!
  end
end

When("I visit the listings page") do
  visit listings_path
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I press {string}") do |button|
  click_button button
end

Then("I should see listing title {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see listing title {string}") do |text|
  expect(page).not_to have_content(text)
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end