class SessionsController < ApplicationController
  def create
    candidate = User.find_by(email: params[:email].to_s.strip.downcase)

    if candidate&.authenticate(params[:password])
      if candidate.email_verified?
        session[:user_id] = candidate.id
        redirect_to root_path, notice: "Logged in successfully."
      else
        flash.now[:alert] = "Your CUHK email has not been verified yet. Please check your email."
        render "login/index", status: :unprocessable_content
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render "login/index", status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully."
  end
end
