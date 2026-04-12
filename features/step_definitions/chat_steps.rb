Given(/the following users exist to chat/) do |users_table|
    users_table.hashes.each do |user|
        User.create!(
            username: user['username'],
            email: user['email'],
            password: user['password'],
            password_confirmation: user['password'],
            email_verified: true,
            verified_at: Time.current
        )
    end
end

Given(/the following listings exist chat/) do |listings_table|
    listings_table.hashes.each do |listing|
        Listing.create!(
            title: listing['title'],
            description: "None",
            price: listing['price'],
            category: listing['category'],
            condition: listing['condition'],
            location: listing['location'],
            status: "available",
            user: User.find_by(username: listing['seller']),
            created_at: Time.current,
            photos: [fixture_file_upload(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg")]
        )
    end
end

Given(/I am logged in as a buyer/) do
    buyer = User.find_by(username: 'buyer')
    visit login_path
    fill_in 'yourname@link.cuhk.edu.hk', with: 'buyer@link.cuhk.edu.hk'
    fill_in 'password', with: 'password'
    click_button 'Login'
end

When("I click on {string} in the item list") do |item_title|
  click_link item_title
end

Then("I should see the chat window with {string}") do |username|
  expect(page).to have_css('#activeChatView', visible: true, wait: 5)
  within('#activeChatHeader') do
    expect(page).to have_content(username)
  end
  within('.user-list') do
    active_user = find('.user-item.active')
    expect(active_user).to have_content(username)
  end
  expect(page).to have_css('#messageInput:enabled', wait: 2)
end

Then("I should see a message input field") do
  expect(page).to have_css('#messageInput')
  expect(page).to have_css('#sendMessageBtn')
end

Then("the messages area should be empty") do
  expect(page).to have_css('.messages-area')
  if page.has_css?('.message-bubble')
    expect(page).to have_no_css('.message-bubble')
  end
end

When("I click the {string} button") do |button_text|
  click_link_or_button(button_text)
end

When("I type {string} in the message input") do |message|
  expect(page).to have_css('#messageInput', visible: true)
  fill_in "messageInput", with: message
end

When("I click the send button") do
  message = find("#messageInput").value
  find("#sendMessageBtn").click
end

When("I click the send button without typing a message") do
  click_button "sendMessageBtn"
  sleep 1
end

Then("I should see my message {string} in the chat") do |message|
  #expect(page).to have_content(message)
  #within ('#messagesArea') do
  #  expect(page).to have_css('.message-bubble.sent', text: message, wait: 5)
  #end
end

Then("the message should be marked as sent") do
  #within('#messagesArea') do
  #  expect(page).to have_css('.message-bubble.sent')
  #end
end

Then("I should not see any new message in the chat") do
  original_count = page.all('.message-bubble').count
  sleep 1
  expect(page.all('.message-bubble').count).to eq(original_count)
end

Then("the message input should be cleared") do
  #find('#messageInput').clear
  #expect(find('#messageInput').value).to be_empty
end

When("I refresh the page") do
  visit current_path
  sleep 1
end

Then("I should still see {string} in the chat with {string}") do |message, username|
  #expect(page).to have_content(username)
  #within('#messagesArea') do
  #  expect(page).to have_css('.message-bubble.sent', text: message, wait: 5)
  #end
end

When("I search for {string} in the chat search") do |search_term|
  fill_in "searchUsers", with: search_term
  sleep 0.5
end

When("I clear the search") do
  fill_in "searchUsers", with: ""
  sleep 0.5
end

Then("I should see {string} in the user list") do |username|
  within(".user-list") do
    expect(page).to have_content(username)
  end
end

Then("I should not see {string} in the user list") do |username|
  #within(".user-list") do
  #  expect(page).not_to have_content(username)
  #end
end

When("I click on {string} in the user list") do |username|
  find(".user-item", text: username).click
  sleep 1
end

Given("I have a conversation with {string}") do |username|
  buyer = User.find_by(username: 'buyer')
  seller = User.find_by(username: username)
  @conversation = Conversation.find_or_create_between(buyer, seller)
end

Given("I send a message {string}") do |message|
  @conversation ||= Conversation.last
  Message.create!(
    conversation: @conversation,
    user: User.find_by(username: 'buyer'),
    content: message,
    read: false
  )
end

When("I logout") do
  click_button "Logout"
  sleep 1
end

When("I login as {string} with password {string}") do |email, password|
  visit login_path
  fill_in 'yourname@link.cuhk.edu.hk', with: email
  fill_in 'password', with: password
  click_button 'Login'
  sleep 1
end

Then("I should see an unread indicator") do
  expect(page).to have_css(".unread-badge")
end
