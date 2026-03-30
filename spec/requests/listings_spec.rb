require 'rails_helper'

RSpec.describe "Listings", type: :request do
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

  def create_listing_with_photo(attributes = {})
    listing = Listing.new(
      title: attributes[:title] || "Default Title",
      price: attributes[:price] || 100,
      category: attributes[:category] || "Electronics",
      condition: attributes[:condition] || "Good",
      location: attributes[:location] || "Campus",
      description: attributes[:description] || "Default description",
      status: 'available',
      user: attributes[:user] || user
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

  def login(user)
    post login_path, params: {
      email: user.email,
      password: "Password123"
    }
  end


  describe "GET /listings" do
    let!(:study_chair) do
      create_listing_with_photo(
        title: "Study Chair",
        price: 120,
        category: "Furniture",
        condition: "Good",
        location: "Sha Tin",
        description: "Black wooden chair",
        status: 'available',
       user: user
      )
    end

    let!(:calculator) do
      create_listing_with_photo(
        title: "Casio Calculator",
        price: 80,
        category: "Electronics",
        condition: "Like New",
        location: "Ma On Shan",
        description: "Scientific calculator",
        status: 'available',
        user: user
      )
    end

    it "returns http success" do
      get listings_path
      expect(response).to have_http_status(:success)
    end

    it "displays listings" do
        create_listing_with_photo(
          title: "Laptop",
          price: 500,
          category: "Electronics",
          condition: "Good",
          location: "Campus",
          description: "Nice laptop",
          status: 'available',
          user: user
        )

        get listings_path
        expect(response.body).to include("Laptop")
    end


    it "filters listings by keyword" do
      get listings_path, params: { q: "chair" }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Study Chair")
      expect(response.body).not_to include("Casio Calculator")
    end

    it "filters listings by category" do
      get listings_path, params: { categories: [ "Furniture" ] }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Study Chair")
      expect(response.body).not_to include("Casio Calculator")
    end

    it "filters listings by condition" do
      get listings_path, params: { conditions: [ "Good" ] }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Study Chair")
      expect(response.body).not_to include("Casio Calculator")
    end
  end








  describe "GET /sell" do
    it "redirects when not logged in" do
      get sell_path
      expect(response).to have_http_status(303).or have_http_status(302)
    end

    it "returns success when logged in" do
      login(user)
      get sell_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /listings/:id" do
    let!(:listing) do
      create_listing_with_photo(
        title: "Test Item",
        price: 100,
        category: "Electronics",
        condition: "Good",
        location: "Campus",
        description: "A test item",
        status: 'available',
        user: user
      )
    end

    it "returns http success" do
      get listing_path(listing)
      expect(response).to have_http_status(:success)
    end

    it "shows listing details" do
      get listing_path(listing)

      expect(response.body).to include("Test Item")
      expect(response.body).to include("$100.00")
      expect(response.body).to include("Electronics")
    end
  end

  describe "POST /sell" do
    let(:image) do
      fixture_file_upload(
        Rails.root.join("spec/fixtures/files/test_image.jpg"),
        "image/jpeg"
      )
    end

    let(:valid_params) do
      {
        listing: {
          title: "New Item",
          price: 200,
          category: "Electronics",
          condition: "Good",
          location: "Campus",
          description: "Brand new",
          status: 'available',
          photos: [ image ]
        }
      }
    end

    it "redirects when not logged in" do
      post sell_path, params: valid_params
      expect(response).to have_http_status(303).or have_http_status(302)
    end

    it "creates a listing when logged in" do
      login(user)

      expect { post sell_path, params: valid_params }.to change(Listing, :count).by(1)

      listing = Listing.last

      expect(listing.photos).to be_attached
      expect(listing.photos.count).to eq(1)

      expect(response).to redirect_to(listing)
    end

    it "fails with invalid params" do
      login(user)

      post sell_path, params: {
        listing: { title: "" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /listings/:id" do
    let!(:listing) do
      create_listing_with_photo(
        title: "Test Item",
        user: user
      )
    end

    context "when logged in as owner" do
      before { login(user) }

      it "deletes the listing" do
        expect {
          delete listing_path(listing)
        }.to change(Listing, :count).by(-1)

        expect(response).to redirect_to(listings_path)
        expect(flash[:notice]).to eq("Listing deleted successfully！")
      end
    end
  end

  describe "PATCH /listings/:id" do
    let!(:listing) do
      create_listing_with_photo(
        title: "Original Title",
        price: 100,
        category: "Electronics",
        condition: "Good",
        location: "Campus",
        description: "Original description",
        status: 'available',
        user: user
      )
    end

    let!(:another_user) do
      User.create!(
        email: "another_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
        username: "anotheruser",
        password: "Password123",
        password_confirmation: "Password123",
        email_verified: true,
        verified_at: Time.current
      )
    end

    let!(:another_users_listing) do
      create_listing_with_photo(
        title: "Another User's Item",
        user: another_user
      )
    end

    let(:new_image) do
      fixture_file_upload(
        Rails.root.join("spec/fixtures/files/test_image.jpg"),
        "image/jpeg"
      )
    end

    let(:valid_update_params) do
      {
        listing: {
          title: "Updated Title",
          price: 150,
          category: "Textbooks",
          condition: "Like New",
          location: "United College",
          description: "Updated description",
          status: 'available'

        }
      }
    end

    context "when logged in as owner" do
      before { login(user) }

      it "updates the listing successfully" do
        patch listing_path(listing), params: valid_update_params

        listing.reload
        expect(listing.title).to eq("Updated Title")
        expect(listing.price).to eq(150)
        expect(listing.category).to eq("Textbooks")
        expect(listing.condition).to eq("Like New")
        expect(listing.location).to eq("United College")
        expect(listing.description).to eq("Updated description")

        expect(response).to redirect_to(listing)
        expect(flash[:notice]).to eq("Listing updated successfully！")
      end

      it "adds new photos to the listing" do
        initial_photo_count = listing.photos.count

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            description: "Updated description",
            status: 'available',
            photos: [ new_image ]
          }
        }

        listing.reload
        expect(listing.photos.count).to eq(initial_photo_count + 1)
      end

      it "removes specified photos" do
        # First add an extra photo so we have 2 photos total
        listing.photos.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
          filename: 'extra_image.jpg',
          content_type: 'image/jpeg'
        )
        listing.reload

        expect(listing.photos.count).to eq(2) # Verify we have 2 photos

        photo_id_to_remove = listing.photos.first.id
        photo_id_to_keep = listing.photos.last.id

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            status: 'available',
            description: "Updated description"
          },
          remove_photos: photo_id_to_remove.to_s
        }

        listing.reload
        expect(listing.photos.count).to eq(1) # Should have 1 photo left
        expect(listing.photos.find_by(id: photo_id_to_remove)).to be_nil
        expect(listing.photos.find_by(id: photo_id_to_keep)).to be_present
      end

      it "prevents removing all photos" do
        # Ensure we only have 1 photo
        expect(listing.photos.count).to eq(1)

        photo_id = listing.photos.first.id

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            status: 'available',
            description: "Updated description"
          },
          remove_photos: photo_id.to_s
        }

        expect(response).to have_http_status(:unprocessable_entity)

        listing.reload
        expect(listing.photos.count).to eq(1) # Photo should still exist
        expect(listing.photos.first.id).to eq(photo_id)
      end

      it "allows removing all photos when adding new ones" do
        photo_id = listing.photos.first.id

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            status: 'available',
            description: "Updated description",
            photos: [ new_image ]
          },
          remove_photos: photo_id.to_s
        }

        listing.reload
        expect(listing.photos.count).to eq(1) # Should have the new photo
        expect(listing.photos.find_by(id: photo_id)).to be_nil
      end

      it "adds multiple new photos" do
        initial_photo_count = listing.photos.count

        # Create 3 new images
        new_images = 3.times.map do |i|
          fixture_file_upload(
            Rails.root.join("spec/fixtures/files/test_image.jpg"),
            "image/jpeg"
          )
        end

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            status: 'available',
            description: "Updated description",
            photos: new_images
          }
        }

        listing.reload
        expect(listing.photos.count).to eq(initial_photo_count + 3)
      end

      it "prevents exceeding maximum photo limit (8 photos)" do
        7.times do |i|
          listing.photos.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
            filename: "extra_image_#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end

        listing.reload
        expect(listing.photos.count).to eq(8)

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            status: 'available',
            description: "Updated description",
            photos: [ new_image ]
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(listing.reload.photos.count).to eq(8)
      end

      it "allows removing photos while staying within limit" do
        7.times do |i|
          listing.photos.attach(
            io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
            filename: "extra_image_#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end

        listing.reload
        expect(listing.photos.count).to eq(8)


        photos_to_remove = listing.photos.first(2).map(&:id).join(",")

        patch listing_path(listing), params: {
          listing: {
            title: "Updated Title",
            price: 150,
            category: "Textbooks",
            condition: "Like New",
            location: "United College",
            status: 'available',
            description: "Updated description",
            photos: [ new_image ]
          },
          remove_photos: photos_to_remove
        }

        listing.reload
        expect(listing.photos.count).to eq(7) # 8 - 2 + 1 = 7
      end

      it "handles invalid updates" do
        patch listing_path(listing), params: {
          listing: { title: "" } # Invalid: title can't be blank
        }

        expect(response).to have_http_status(:unprocessable_entity)

        listing.reload
        expect(listing.title).to eq("Original Title")
      end

      it "cannot update another user's listing" do
        patch listing_path(another_users_listing), params: valid_update_params

        expect(response).to redirect_to(another_users_listing)
        expect(flash[:alert]).to eq("You are not authorized to perform this action")

        another_users_listing.reload
        expect(another_users_listing.title).to eq("Another User's Item")
      end
    end

    context "when logged in as non-owner" do
      before { login(another_user) }

      it "cannot update another user's listing" do
        patch listing_path(listing), params: valid_update_params

        expect(response).to redirect_to(listing)
        expect(flash[:alert]).to eq("You are not authorized to perform this action")

        listing.reload
        expect(listing.title).to eq("Original Title")
      end
    end

    context "when not logged in" do
      it "cannot update any listing" do
        patch listing_path(listing), params: valid_update_params

        expect(response).to have_http_status(302).or have_http_status(303)

        listing.reload
        expect(listing.title).to eq("Original Title")
      end
    end
  end
end
