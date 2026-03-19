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
        user: user
      )

      get listings_path
      expect(response.body).to include("Laptop")
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
end
