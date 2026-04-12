Given("I am not logged in") do
  # First try to visit a page to ensure we have a page context
  visit root_path
  sleep 0.5

  # Try multiple ways to logout
  if page.has_button?("Logout")
    click_button "Logout"
  elsif page.has_link?("Logout")
    click_link "Logout"
  elsif page.has_css?(".session-badge")
    # Click on the session badge to access dropdown
    find(".session-badge").click
    sleep 0.5
    if page.has_link?("Logout")
      click_link "Logout"
    elsif page.has_button?("Logout")
      click_button "Logout"
    end
  end

  # Clear any session data
  Capybara.reset_sessions!
  visit root_path
  sleep 0.5
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

Given("I have a listing") do
  visit sell_path
  fill_in "Listing title", with: "iPhone 12"
  fill_in "Price", with: "250"
  select "Electronics", from: "Category"
  select "Like New", from: "Condition"
  fill_in "Location", with: "S.H. Ho College"
  fill_in "Description", with: "A like new iPhone 12 for sale!"

  files = []
  count = 2
  count.times do |i|
    temp_file = Tempfile.new([ "test_photo_#{i}", '.jpg' ])
    temp_file.write("\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00")
    temp_file.rewind
    files << temp_file.path
  end
  attach_file("listing[photos][]", files)
  sleep 0.5
  click_button "List it!"
  @listing = Listing.last
end
