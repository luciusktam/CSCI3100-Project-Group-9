class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?, :dark_mode?

  before_action :read_theme_cookie

  private

  def read_theme_cookie
    @dark_mode = cookies[:theme_preference] == "dark"
  end

  def dark_mode?
    @dark_mode || false
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    @current_user unless @current_user&.banned?
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    return if user_signed_in?

    flash[:alert] = "Please log in before listing items for sale"
    redirect_to login_path, status: :see_other
  end

  def authenticate_user_chat!
    return if user_signed_in?

    respond_to do |format|
      format.json { render json: { error: "Unauthorized", message: "Please log in before accessing the chat" }, status: :unauthorized }
      format.all {
        flash[:alert] = "Please log in before accessing the chat"
        redirect_to login_path, status: :see_other
      }
    end
  end
end
