class ProfileController < ApplicationController
  before_action :require_login

  def index
  end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    user = current_user

    if user.destroy
      reset_session
      redirect_to root_path, notice: "Your account has been deleted."
    else
      redirect_to profile_path, alert: "Unable to delete account. Please try again."
    end
  end

  private

  def require_login
    return if user_signed_in?

    redirect_to login_path, alert: "Please log in first."
  end

  def profile_params
    params.require(:user).permit(:username, :avatar)
  end
end
