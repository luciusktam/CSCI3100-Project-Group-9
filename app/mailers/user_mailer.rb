class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verify_url = verify_email_url(token: user.verification_token)
    mail(
      to:      user.email,
      subject: "CUMarket \u2013 Verify your CUHK email address"
    )
  end
end
