Given(/the following users exist/) do |users_table|
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

Given(/the following listings exist/) do |listings_table|
    listings_table.hashes.each do |listing|
        Listing.create!(
            title: listing['title'],
            description: "None",
            price: listing['price'],
            category: listing['category'],
            condition: listing['condition'],
            location: listing['location'],
            user: User.find_by(username: listing['seller']),
            created_at: Time.current,
            photos: [fixture_file_upload(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg") ]
        )
    end
end

Given(/I am logged in as a buyer/) do
    buyer = User.find_by(username: 'buyer')
    visit login_path
    fill_in 'Email', with: 'buyer@link.cuhk.edu.hk'
    fill_in 'Password', with: 'password'
    click_button 'Login'
end