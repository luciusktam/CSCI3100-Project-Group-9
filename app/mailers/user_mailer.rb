class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verify_url = verify_email_url(token: user.verification_token)
    mail(
      to:      user.email,
      subject: "CUMarket \u2013 Verify your CUHK email address"
    )
  end

  def password_reset_email(user)
    @user = user
    @reset_url = edit_password_url(token: user.reset_password_token)
    mail(
      to:      user.email,
      subject: "CUMarket \u2013 Reset your password"
    )
  end
end
