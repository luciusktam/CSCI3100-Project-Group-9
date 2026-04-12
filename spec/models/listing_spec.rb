require 'rails_helper'

RSpec.describe Listing, type: :model do
  let(:user) { User.create!(
    email: "test1@link.cuhk.edu.hk",
    username: "testuser",
    password: "Password123",
    password_confirmation: "Password123"
  )}
  let(:image) do
      fixture_file_upload(
        Rails.root.join("spec/fixtures/files/test_image.jpg"),
        "image/jpeg"
      )
    end

  let(:valid_attributes) {
    {
      title: "Test Item",
      price: 100,
      category: "Electronics",
      condition: "Good",
      location: "Chung Chi College",
      description: "This is a test item",
      user: user,
      status: "available",
      photos: [ image ]
    }
  }

  describe "validations" do
    context "with valid attributes" do
      it "is valid" do
        listing = Listing.new(valid_attributes)
        expect(listing).to be_valid
      end
    end

    context "without a title" do
      it "is not valid" do
        listing = Listing.new(valid_attributes.merge(title: nil))
        expect(listing).not_to be_valid
        expect(listing.errors[:title]).to include("can't be blank")
      end
    end

    context "without a price" do
      it "is not valid" do
        listing = Listing.new(valid_attributes.merge(price: nil))
        expect(listing).not_to be_valid
        expect(listing.errors[:price]).to include("can't be blank")
      end
    end

    context "with negative price" do
      it "is not valid" do
        listing = Listing.new(valid_attributes.merge(price: -10))
        expect(listing).not_to be_valid
        expect(listing.errors[:price]).to include("must be greater than or equal to 0")
      end
    end

    context "without a category" do
      it "is not valid" do
        listing = Listing.new(valid_attributes.merge(category: nil))
        expect(listing).not_to be_valid
        expect(listing.errors[:category]).to include("can't be blank")
      end
    end

    context "without a condition" do
      it "is not valid" do
        listing = Listing.new(valid_attributes.merge(condition: nil))
        expect(listing).not_to be_valid
        expect(listing.errors[:condition]).to include("can't be blank")
      end
    end

    context "without a user" do
      it "is not valid" do
        listing = Listing.new(valid_attributes.merge(user: nil))
        expect(listing).not_to be_valid
        expect(listing.errors[:user]).to include("must exist")
      end
    end
  end

  describe "associations" do
    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it "has many photos attached" do
      expect(Listing.new).to respond_to(:photos)
      expect(Listing.new.photos).to be_an_instance_of(ActiveStorage::Attached::Many)
    end
  end

  describe "photo attachments" do
    let(:listing) { Listing.new(valid_attributes.except(:photos)) }

    it "can have photos attached" do
      file = Tempfile.new([ 'test-image', '.jpg' ])
      file.write('fake image content')
      file.rewind

      listing.photos.attach(
        io: file,
        filename: 'test-image.jpg',
        content_type: 'image/jpg'
      )

      expect(listing.photos).to be_attached
      expect(listing.photos.count).to eq(1)

      file.close
      file.unlink
    end

    it "can have multiple photos attached" do
      files = []

      3.times do |i|
        file = Tempfile.new([ "test-image-#{i}", '.jpg' ])
        file.write("fake image content #{i}")
        file.rewind
        files << file

        listing.photos.attach(
          io: file,
          filename: "test-image-#{i}.jpg",
          content_type: 'image/jpg'
        )
      end

      expect(listing.photos.count).to eq(3)

      files.each do |file|
        file.close
        file.unlink
      end
    end
  end

  describe "custom validations" do
    let(:listing) { Listing.new(valid_attributes.except(:photos)) }

    context "when attaching more than 8 photos" do
      it "adds an error" do
        files = []


        8.times do |i|
          file = Tempfile.new([ "test-image-#{i}", '.jpg' ])
          file.write("fake image content #{i}")
          file.rewind
          files << file

          listing.photos.attach(
            io: file,
            filename: "test-image-#{i}.jpg",
            content_type: 'image/jpg'
          )
        end


        extra_file = Tempfile.new([ "test-image-extra", '.jpg' ])
        extra_file.write("fake image content extra")
        extra_file.rewind
        files << extra_file

        listing.photos.attach(
          io: extra_file,
          filename: "test-image-extra.jpg",
          content_type: 'image/jpg'
        )


        listing.valid?
        expect(listing.errors[:photos]).to include("maximum 8 photos allowed")

        files.each do |file|
          file.close
          file.unlink
        end
      end
    end

    context "when attaching exactly 8 photos" do
      it "is valid" do
        files = []

        8.times do |i|
          file = Tempfile.new([ "test-image-#{i}", '.jpg' ])
          file.write("fake image content #{i}")
          file.rewind
          files << file

          listing.photos.attach(
            io: file,
            filename: "test-image-#{i}.jpg",
            content_type: 'image/jpg'
          )
        end

        expect(listing).to be_valid
        expect(listing.photos.count).to eq(8)

        files.each do |file|
          file.close
          file.unlink
        end
      end
    end
  end

  describe "search_by_keyword (pg_search trigram)" do
    def create_test_listing_with_photo(title:, description:, location:, category:)
      listing = described_class.new(
        title: title,
        description: description,
        location: location,
        price: 100,
        category: category,
        condition: "Good",
        user: user,
        status: "available"
      )
      listing.photos.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
        filename: "test_image.jpg",
        content_type: "image/jpeg"
      )
      listing.save!
      listing
    end

    let!(:post1) { create_test_listing_with_photo(
      title: "Mechanical Keyboard",
      description: "Cherry MX Brown switches",
      location: "Sha Tin",
      category: "Electronics"
    ) }

    let!(:post2) { create_test_listing_with_photo(
      title: "Python Textbook",
      description: "Introduction to programming",
      location: "Campus",
      category: "Textbooks"
    ) }

    let!(:post3) { create_test_listing_with_photo(
      title: "Gaming Mouse",
      description: "Logitech wireless mouse",
      location: "Ma On Shan",
      category: "Electronics"
    ) }

    it "matches by title" do
      results = described_class.search_by_keyword("keyboard")
      expect(results).to include(post1)
    end

    it "matches by description" do
      results = described_class.search_by_keyword("switches")
      expect(results).to include(post1)
    end

    it "matches by location" do
      results = described_class.search_by_keyword("Sha Tin")
      expect(results).to include(post1)
    end

    it "does not match unrelated terms" do
      results = described_class.search_by_keyword("nonexistent_xyz_123")
      expect(results).to be_empty
    end
  end

  describe "#photos_must_be_attached" do
    let(:listing_without_photo) do
      described_class.new(
        title: "No Photo Item",
        price: 50,
        category: "Electronics",
        condition: "Good",
        location: "Campus",
        description: "Test",
        user: user,
        status: "available"
      )
    end

    it "adds error when photos are not attached" do
      listing_without_photo.valid?
      expect(listing_without_photo.errors[:photos]).to include("must be attached")
    end
  end

  describe "database columns" do
    it "has the expected database columns" do
      expected_columns = %w[id title price condition description location category user_id created_at updated_at]
      expect(Listing.column_names).to include(*expected_columns)
    end

    it "has correct column types" do
      expect(Listing.columns_hash['title'].type).to eq :string
      expect(Listing.columns_hash['price'].type).to eq :decimal
      expect(Listing.columns_hash['condition'].type).to eq :string
      expect(Listing.columns_hash['description'].type).to eq :text
      expect(Listing.columns_hash['location'].type).to eq :string
      expect(Listing.columns_hash['category'].type).to eq :string
      expect(Listing.columns_hash['user_id'].type).to eq :integer
    end
  end
end
