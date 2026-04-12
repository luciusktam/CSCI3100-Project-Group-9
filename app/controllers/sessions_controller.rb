class SessionsController < ApplicationController
  def create
    email = params[:email].to_s.strip.downcase
    @prefill_email = email
    candidate = User.find_by(email: email)

    if candidate&.authenticate(params[:password])
      if candidate.banned?
        flash.now[:alert] = "Your account has been suspended. Please contact support."
        render "login/index", status: :forbidden
      elsif candidate.email_verified?
        session[:user_id] = candidate.id
        redirect_to root_path, notice: "Logged in successfully."
      else
        flash.now[:alert] = "Your CUHK email has not been verified yet. Please check your email."
        @unverified_email = email
      end
    else
      flash.now[:alert] = "Invalid email or password."
    end

    render "login/index", status: :unprocessable_content unless performed?
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully."
  end
end
