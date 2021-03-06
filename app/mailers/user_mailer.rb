class UserMailer < ActionMailer::Base
  default from: "notifications@townhallapp.io"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to townhall!')
  end
end
