class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verify_url = verify_email_url(user_id: user.id, token: user.verification_token)
    mail(
      to:      user.email,
      subject: "CUMarket – Verify your CUHK email address"
    )
  end

  def password_reset_email(user, token)
    @user = user
    @reset_url = edit_password_url(token: token)
    mail(
      to:      user.email,
      subject: "CUMarket – Reset your password"
    )
  end
end
