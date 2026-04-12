require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :request do
  let(:admin_email) { "admin_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }
  let(:user_email) { "user_#{SecureRandom.hex(4)}@link.cuhk.edu.hk" }

  let!(:admin) do
    User.create!(
      email: admin_email,
      username: "adminuser",
      password: "Password123",
      password_confirmation: "Password123",
      email_verified: true,
      verified_at: Time.current,
      role: :admin
    )
  end

  let!(:user) do
    User.create!(
      email: user_email,
      username: "regularuser",
      password: "Password123",
      password_confirmation: "Password123",
      email_verified: true,
      verified_at: Time.current,
      role: :user
    )
  end

  let!(:another_admin) do
    User.create!(
      email: "another_admin_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
      username: "anotheradmin",
      password: "Password123",
      password_confirmation: "Password123",
      email_verified: true,
      verified_at: Time.current,
      role: :admin
    )
  end

  def login(email)
    post login_path, params: { email: email, password: "Password123" }
  end

  describe "GET /admin/dashboard" do
    it "redirects when not logged in" do
      get admin_dashboard_path
      expect(response).to redirect_to(login_path)
    end

    it "redirects when logged in as regular user" do
      login(user_email)
      get admin_dashboard_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You must be an admin to access that page.")
    end

    it "returns success when logged in as admin" do
      login(admin_email)
      get admin_dashboard_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/users/:id/ban" do
    context "when logged in as admin" do
      before { login(admin_email) }

      it "bans user permanently" do
        post admin_ban_user_path(user), params: { duration: "permanent" }
        user.reload
        expect(user.banned_until).to be > Time.current
        expect(flash[:notice]).to include("permanently banned")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "bans user for specified days" do
        post admin_ban_user_path(user), params: { duration: "7" }
        user.reload
        expected_ban = 7.days.from_now
        expect(user.banned_until).to be_between(expected_ban - 1.second, expected_ban + 1.second)
        expect(flash[:notice]).to include("7 days")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "shows alert when no duration specified" do
        post admin_ban_user_path(user), params: { duration: "" }
        expect(flash[:alert]).to eq("Please specify a ban duration.")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "prevents admin from banning self" do
        post admin_ban_user_path(admin)
        expect(flash[:alert]).to eq("You cannot ban yourself.")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "prevents admin from banning another admin" do
        post admin_ban_user_path(another_admin)
        expect(flash[:alert]).to eq("Cannot ban an admin.")
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "when logged in as regular user" do
      before { login(user_email) }

      it "redirects to root" do
        post admin_ban_user_path(user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You must be an admin to access that page.")
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        post admin_ban_user_path(user)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /admin/users/:id/unban" do
    context "when logged in as admin" do
      before { login(admin_email) }

      it "unbans a banned user" do
        user.update!(banned_until: 1.day.ago)
        post admin_unban_user_path(user)
        user.reload
        expect(user.banned_until).to be_nil
        expect(flash[:notice]).to include("unbanned")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "prevents admin from unbanning self" do
        post admin_unban_user_path(admin)
        expect(flash[:alert]).to eq("You cannot unban yourself.")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "prevents admin from unbanning another admin" do
        post admin_unban_user_path(another_admin)
        expect(flash[:alert]).to eq("Cannot unban an admin.")
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "when logged in as regular user" do
      before { login(user_email) }

      it "redirects to root" do
        post admin_unban_user_path(user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    context "when logged in as admin" do
      before { login(admin_email) }

      it "deletes a user" do
        target = User.create!(
          email: "target_#{SecureRandom.hex(4)}@link.cuhk.edu.hk",
          username: "targetuser",
          password: "Password123",
          password_confirmation: "Password123",
          email_verified: true,
          verified_at: Time.current
        )
        expect {
          delete admin_delete_user_path(target)
        }.to change(User, :count).by(-1)
        expect(flash[:notice]).to include("deleted")
        expect(response).to redirect_to(admin_dashboard_path)
      end

      it "prevents admin from deleting self" do
        delete admin_delete_user_path(admin)
        expect(flash[:alert]).to eq("You cannot delete yourself.")
        expect(response).to redirect_to(admin_dashboard_path)
        expect(User.exists?(admin.id)).to be true
      end

      it "prevents admin from deleting another admin" do
        delete admin_delete_user_path(another_admin)
        expect(flash[:alert]).to eq("Cannot delete an admin.")
        expect(response).to redirect_to(admin_dashboard_path)
        expect(User.exists?(another_admin.id)).to be true
      end
    end

    context "when logged in as regular user" do
      before { login(user_email) }

      it "redirects to root" do
        delete admin_delete_user_path(user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/listings/:id" do
    let(:listing) do
      listing = Listing.new(
        title: "Test Item",
        price: 100,
        category: "Electronics",
        condition: "Good",
        location: "Campus",
        description: "Description",
        status: "available",
        user: user
      )
      listing.photos.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
      listing.save!
      listing
    end

    context "when logged in as admin" do
      before { login(admin_email) }

      it "deletes a listing" do
        listing
        expect {
          delete admin_delete_listing_path(listing)
        }.to change(Listing, :count).by(-1)
        expect(flash[:notice]).to include("deleted")
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "when logged in as regular user" do
      before { login(user_email) }

      it "redirects to root" do
        delete admin_delete_listing_path(listing)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/posts/:id" do
    let(:test_post) { CommunityPost.create!(title: "Test Post", content: "Content", user: user) }

    context "when logged in as admin" do
      before { login(admin_email) }

      it "deletes a post" do
        test_post
        expect {
          delete admin_delete_post_path(test_post)
        }.to change(CommunityPost, :count).by(-1)
        expect(flash[:notice]).to include("deleted")
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "when logged in as regular user" do
      before { login(user_email) }

      it "redirects to root" do
        delete admin_delete_post_path(test_post)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
