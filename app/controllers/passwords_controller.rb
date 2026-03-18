class PasswordsController < ApplicationController
  before_action :load_user_from_token, only: [:edit, :update]

  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)

    if user
      token = user.generate_password_reset_token!
      user.update!(reset_password_sent_at: Time.current)
      UserMailer.password_reset_email(user, token).deliver_later
    end

    redirect_to login_path, notice: "If that email exists, a password reset link has been sent."
  end

  def edit
    if @user.password_reset_token_expired?
      redirect_to forgot_password_path, alert: "Reset link has expired. Please request a new one."
    end
  end

  def update
    if @user.password_reset_token_expired?
      redirect_to forgot_password_path, alert: "Reset link has expired. Please request a new one."
      return
    end

    if @user.update(password_params)
      @user.clear_password_reset_token!
      redirect_to login_path, notice: "Password updated. Please log in."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def load_user_from_token
    token = params[:token].to_s
    @user = User.all.find { |u| u.reset_password_token_matches?(token) }
    return if @user

    redirect_to forgot_password_path, alert: "Invalid reset link."
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end