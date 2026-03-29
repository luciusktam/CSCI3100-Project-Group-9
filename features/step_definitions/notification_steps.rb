Given('I am on the homepage page') do
  visit root_path
end

Given('I am on the chat page') do
  visit chat_path
end

When('{string} sends me a new message') do |username|
  @sender = User.find_by(username: username)
  @conversation = Conversation.find_or_create_between(@current_user, @sender)
  
  # Create a new message as the sender
  @new_message = Message.create!(
    conversation: @conversation,
    user: @sender,
    content: "This is a new test message sent at #{Time.current}"
  )
  
  # Trigger the notification via JavaScript
  page.execute_script(<<-JS, @sender.id, @sender.username, @new_message.content)
    var senderId = arguments[0];
    var senderName = arguments[1];
    var messageContent = arguments[2];
    
    var testMessage = {
      sender_id: senderId,
      sender_name: senderName,
      content: messageContent,
      is_current_user: false,
      time_ago: "just now"
    };
    
    if (window.notificationManager) {
      window.notificationManager.handleNewMessage(testMessage);
      console.log("Message triggered:", testMessage);
    } else {
      console.error("Notification manager not found");
    }
  JS
  
  # Wait for the notification to process
  sleep(1)
end

Then('I should see a notification badge on the chat button at the header') do
  # Find the chat button and badge
  expect(page).to have_selector('#navChatLink', wait: 5)
  
  # Check if badge is visible and has content
  badge = find('#chatNavBadge', visible: :all)
  expect(badge).to be_visible
  expect(badge.text).to match(/\d+/)
  expect(badge.text.to_i).to be > 0
end

Then('I should see a notification badge on the chat sidebar for Bob') do
  # Wait for the badge to appear
  expect(page).to have_selector(".user-item[data-user-id='#{@sender.id}'] .unread-badge", wait: 5)
  
  badge = find(".user-item[data-user-id='#{@sender.id}'] .unread-badge")
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

Then('I should be redirected to the chat page') do
  expect(current_path).to eq(chat_path)
end

When('I click {string} on the chat sidebar') do |username|
  user = User.find_by(username: username)
  find(".user-item[data-user-id='#{user.id}']").click
end

Then('I should not see a toast notification appear') do
  # Check that no toast notification is present
  expect(page).to have_no_selector('.notification-toast')
end

# Additional step definitions for better coverage

Then('I should see a toast notification appear') do
  expect(page).to have_selector('.notification-toast', wait: 5)
  toast = find('.notification-toast')
  expect(toast).to be_visible
end

Then('the toast notification should show {string}\'s name and the message preview') do |username|
  expect(page).to have_selector('.notification-toast', wait: 5)
  toast_text = find('.notification-toast').text
  expect(toast_text.downcase).to include(username.downcase)
  expect(toast_text).to include(@new_message.content[0..30])
end

Then('the page title should show an unread count indicator') do
  title = page.title
  expect(title).to match(/^\(\d+\)/)
end

When('I click on the toast notification') do
  find('.notification-toast').click
  wait_for_page_load
end

Then('I should be redirected to the chat with {string}') do |username|
  user = User.find_by(username: username)
  expect(current_path).to eq(chat_path(user))
end

Then('the unread count for {string} should be cleared') do |username|
  user = User.find_by(username: username)
  # Check that the badge is removed or hidden
  badge = page.find(".user-item[data-user-id='#{user.id}'] .unread-badge", visible: :all)
  expect(badge).not_to be_visible
end

Then('the notification badge should persist') do
  expect(page).to have_selector('#chatNavBadge', visible: true)
  badge = find('#chatNavBadge', visible: :all)
  expect(badge).to be_visible
  expect(badge.text.to_i).to be > 0
end

When('I send a message to {string}') do |username|
  user = User.find_by(username: username)
  
  # Ensure we're in the correct chat
  if current_path != chat_path(user)
    visit chat_path(user)
  end
  
  fill_in 'messageInput', with: 'This is my reply message'
  find('#sendMessageBtn').click
end