require 'rails_helper'

RSpec.describe "ListingShowPage", type: :system do
  let(:user_email) { "user_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }

  let!(:user) do
    User.create!(
      email: user_email,
      username: "testuser",
      password: "Password123",
      password_confirmation: "Password123",
      email_verified: true,
      verified_at: Time.current
    )
  end

  def create_listing_with_multiple_photos
    listing = Listing.new(
      title: "Multiple Photos Item",
      price: 100,
      category: "Electronics",
      condition: "Good",
      location: "Campus",
      description: "Item with multiple photos",
      status: "available",
      user: user
    )

    # Add 4 test images
    4.times do |i|
      file_path = Rails.root.join("spec/fixtures/files/test_image.jpg")

      listing.photos.attach(
        io: File.open(file_path),
        filename: "test_image#{i+1}.jpg",
        content_type: 'image/jpeg'
      )
    end

    listing.save!
    listing
  end

  def create_listing_with_single_photo
    listing = Listing.new(
      title: "Single Photo Item",
      price: 100,
      category: "Electronics",
      condition: "Good",
      location: "Campus",
      status: "available",
      description: "Item with one photo",
      user: user
    )

    file_path = Rails.root.join("spec/fixtures/files/test_image.jpg")
    listing.photos.attach(
      io: File.open(file_path),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )

    listing.save!
    listing
  end

  describe "Image Carousel Functionality", js: true do
    it "displays left and right navigation buttons when there are more than 3 photos" do
      listing = create_listing_with_multiple_photos
      visit listing_path(listing)

      expect(page).to have_selector('.nav-btn.prev')
      expect(page).to have_selector('.nav-btn.next')
    end

    it "does not display navigation buttons when there are 3 or fewer photos" do
      listing = create_listing_with_single_photo
      visit listing_path(listing)

      expect(page).not_to have_selector('.nav-btn.prev')
      expect(page).not_to have_selector('.nav-btn.next')
    end

    it "scrolls right when clicking the right arrow button", js: true do
      listing = create_listing_with_multiple_photos
      visit listing_path(listing)

      track = find('.image-track')
      initial_scroll = evaluate_script("arguments[0].scrollLeft", track)

      find('.nav-btn.next').click
      sleep 0.2

      new_scroll = evaluate_script("arguments[0].scrollLeft", track)
      expect(new_scroll).to be > initial_scroll
    end

    it "scrolls left when clicking the left arrow button", js: true do
      listing = create_listing_with_multiple_photos
      visit listing_path(listing)


      find('.nav-btn.next').click
      sleep 0.2

      track = find('.image-track')
      initial_scroll = evaluate_script("arguments[0].scrollLeft", track)

      find('.nav-btn.prev').click
      sleep 0.2

      new_scroll = evaluate_script("arguments[0].scrollLeft", track)
      expect(new_scroll).to be < initial_scroll
    end
  end

  describe "Image Modal Functionality", js: true do
    it "displays the modal when clicking an image" do
      listing = create_listing_with_single_photo
      visit listing_path(listing)

      expect(page).not_to have_selector('#imageModal', visible: true)

      first('.listing-image').click

      expect(page).to have_selector('#imageModal', visible: true)
      expect(page).to have_selector('#modalImg', visible: true)
    end

    it "shows the clicked image in the modal" do
      listing = create_listing_with_multiple_photos
      visit listing_path(listing)

      # Click the second image
      all('.listing-image')[1].click

      modal_img_src = find('#modalImg')['src']
      clicked_img_src = all('.listing-image')[1]['src']

      expect(modal_img_src).to eq(clicked_img_src)
    end

    it "closes the modal when clicking on it" do
      listing = create_listing_with_single_photo
      visit listing_path(listing)

      first('.listing-image').click
      expect(page).to have_selector('#imageModal', visible: true)

      find('#imageModal').click

      expect(page).not_to have_selector('#imageModal', visible: true)
    end
  end
end
