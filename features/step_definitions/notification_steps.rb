Given('I am on the homepage page') do
  visit root_path
end

Given('I am on the chat page') do
  visit chat_path
end

When('{string} sends me a new message') do |username|
  @conversation ||= Conversation.last
  
  # Create a new message as the sender
  @new_message = Message.create!(
    conversation: @conversation,
    user: User.find_by(username: 'buyer'),
    content: "This is a new test message sent at #{Time.current}",
    read: false
  )
  
  # Wait for the notification to process
  sleep(1)
end

Then("I should see a notification badge on the chat button at the header") do
  expect(page).to have_selector('#chatNavBadge:not([style*="display: none"])', wait: 10)
  
  badge = find('#chatNavBadge')
  expect(badge).to be_visible
  expect(badge.text).to match(/\d+/)
  expect(badge.text.to_i).to be > 0
end

Then("I should see a notification badge on the chat sidebar for {string}") do |sender_name|
  sender = User.find_by(username: sender_name)
  
  expect(page).to have_selector(".user-item[data-user-id='#{sender.id}'] .unread-badge", wait: 10)
  
  badge = find(".user-item[data-user-id='#{sender.id}'] .unread-badge")
  expect(badge).to be_visible
  expect(badge.text).to match(/\d+/)
end

Then('the unread count should be displayed as {string}') do |expected_count|
  badge = find(".user-item[data-user-id='#{@sender.id}'] .unread-badge")
  expect(badge.text).to eq(expected_count)
end

When('I click the chat button') do
  find('#navChatLink').click
end

Then('I should not see a notification badge on the chat button at the header') do
  # Check if badge exists but is hidden, or doesn't exist at all
  badge = find('#chatNavBadge', visible: :all)
  expect(badge).not_to be_visible
end

When('I click {string} on the chat sidebar') do |username|
  user = User.find_by(username: username)
  find(".user-item[data-user-id='#{user.id}']").click
end

Then('I should not see a toast notification appear') do
  # Check that no toast notification is present
  expect(page).to have_no_selector('.notification-toast')
end

Then('I should see a toast notification appear') do
  expect(page).to have_selector('.notification-toast', wait: 5)
  toast = find('.notification-toast')
  expect(toast).to be_visible
end

Then('the page title should show an unread count indicator') do
  title = page.title
  expect(title).to match(/^\(\d+\)/)
end