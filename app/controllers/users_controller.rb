class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.verification_token = SecureRandom.hex(32)

    if @user.save
      UserMailer.verification_email(@user).deliver_later
      redirect_to login_path, notice: "Account created. Verification is still required before login."
    else
      @user.password = nil
      @user.password_confirmation = nil
      render :new, status: :unprocessable_content
    end
  end

  def verify
    user = User.find_by(verification_token: params[:token])

    if user && !user.email_verified?
      user.update!(email_verified: true, verified_at: Time.current, verification_token: nil)
      redirect_to login_path, notice: "Email verified! You can now log in."
    elsif user&.email_verified?
      redirect_to login_path, notice: "Email already verified."
    else
      redirect_to root_path, alert: "Invalid or expired verification link."
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end
