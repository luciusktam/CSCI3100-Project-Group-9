Given('the following users exist:') do |table|
  table.hashes.each do |row|
    attrs = {
      username: row['username'],
      email: row['email'],
      password: row['password'],
      password_confirmation: row['password']
    }

    attrs[:verified] = true if User.column_names.include?('verified')
    attrs[:email_verified] = true if User.column_names.include?('email_verified')
    attrs[:confirmed_at] = Time.current if User.column_names.include?('confirmed_at')

    User.create!(attrs)
  end
end

Given('I am logged in as {string}') do |username|
  user = User.find_by!(username: username)

  visit login_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: 'password123'
  click_button 'Login'
end

Given('there are no community posts') do
  Comment.delete_all if defined?(Comment)
  CommunityPost.delete_all
end

Given('the following community posts exist:') do |table|
  table.hashes.each do |row|
    user = User.find_by!(username: row['username'])

    CommunityPost.create!(
      title: row['title'],
      content: row['content'],
      user: user
    )
  end
end

Given('the following comments exist:') do |table|
  table.hashes.each do |row|
    post = CommunityPost.find_by!(title: row['post_title'])
    user = User.find_by!(username: row['username'])

    Comment.create!(
      body: row['body'],
      user: user,
      community_post: post
    )
  end
end

When('I visit the community page') do
  visit community_path
end

When('I visit the new community post page') do
  visit new_community_post_path
end

When('I visit the community post page for {string}') do |title|
  post = CommunityPost.find_by!(title: title)
  visit community_post_path(post)
end

When('I fill in the community search with {string}') do |query|
  fill_in 'query', with: query
end

Then('I should be on the community page') do
  expect(page).to have_current_path(community_path, ignore_query: true)
end

Then('I should see a community form error') do
  expect(page).to have_css('.community-error-box')
end

When('I follow {string}') do |string|
  click_link string
end

Then('I should not see {string}') do |string|
  expect(page).to have_no_content(string)
end


When('I press the community search button') do
  click_button 'Search'
end


When('I fill in the community field {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press the community button {string}') do |button|
  click_button button
end
