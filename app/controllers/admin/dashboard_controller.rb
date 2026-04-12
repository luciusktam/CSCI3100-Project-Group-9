class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @total_users = User.count
    @total_listings = Listing.count
    @total_posts = CommunityPost.count
    @verified_users = User.where(email_verified: true).count
    @admin_users = User.where(role: :admin).count

    @recent_users = User.order(created_at: :desc).limit(10)
    @recent_listings = Listing.order(created_at: :desc).limit(10)
    @recent_posts = CommunityPost.order(created_at: :desc).limit(10)
  end

  def ban_user
    target = User.find(params[:id])
    if target == current_user
      flash[:alert] = "You cannot ban yourself."
    elsif target.admin?
      flash[:alert] = "Cannot ban an admin."
    else
      duration = params[:duration]
      if duration == "permanent"
        target.update!(banned_until: 100.years.from_now)
        flash[:notice] = "#{target.email} has been permanently banned."
      elsif duration.present?
        target.update!(banned_until: duration.to_i.days.from_now)
        flash[:notice] = "#{target.email} has been banned for #{duration} days."
      else
        flash[:alert] = "Please specify a ban duration."
      end
    end
    redirect_to admin_dashboard_path
  end

  def unban_user
    target = User.find(params[:id])
    if target == current_user
      flash[:alert] = "You cannot unban yourself."
    elsif target.admin?
      flash[:alert] = "Cannot unban an admin."
    else
      target.update!(banned_until: nil)
      flash[:notice] = "#{target.email} has been unbanned."
    end
    redirect_to admin_dashboard_path
  end

  def delete_user
    target = User.find(params[:id])
    if target == current_user
      flash[:alert] = "You cannot delete yourself."
    elsif target.admin?
      flash[:alert] = "Cannot delete an admin."
    else
      target.destroy
      flash[:notice] = "User #{target.email} has been deleted."
    end
    redirect_to admin_dashboard_path
  end

  def delete_listing
    listing = Listing.find(params[:id])
    listing.destroy
    flash[:notice] = "Listing '#{listing.title}' has been deleted."
    redirect_to admin_dashboard_path
  end

  def delete_post
    post = CommunityPost.find(params[:id])
    post.destroy
    flash[:notice] = "Post '#{post.title}' has been deleted."
    redirect_to admin_dashboard_path
  end

  private

  def require_admin
    return if current_user&.admin?

    flash[:alert] = "You must be an admin to access that page."
    redirect_to root_path
  end
end
