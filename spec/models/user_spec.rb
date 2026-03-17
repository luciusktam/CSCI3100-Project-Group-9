require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) do
    described_class.new(
      email: "student@link.cuhk.edu.hk",
      username: "student",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  it "is valid with a CUHK email and password" do
    expect(user).to be_valid
  end

  it "normalizes email before validation" do
    user.email = "  STUDENT@LINK.CUHK.EDU.HK  "

    user.valid?

    expect(user.email).to eq("student@link.cuhk.edu.hk")
  end

  it "rejects non-CUHK emails" do
    user.email = "student@gmail.com"

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is invalid")
  end

  it "requires a username" do
    user.username = nil

    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("can't be blank")
  end

  it "requires a password with minimum length" do
    user.password = "short"
    user.password_confirmation = "short"

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
  end

  it "defaults to the user role" do
    expect(user.role).to eq("user")
  end

  it "allows the admin role" do
    user.role = :admin

    expect(user.admin?).to be(true)
  end

  it "enforces case-insensitive email uniqueness" do
    described_class.create!(
      email: "student@link.cuhk.edu.hk",
      username: "student1",
      password: "Password123",
      password_confirmation: "Password123"
    )

    duplicate = described_class.new(
      email: "STUDENT@link.cuhk.edu.hk",
      username: "student2",
      password: "Password123",
      password_confirmation: "Password123"
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include("has already been taken")
  end
end