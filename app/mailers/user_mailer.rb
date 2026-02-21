class UserMailer < ApplicationMailer
  default from: ENV.fetch('FROM_EMAIL', 'noreply@legalauditor.com')

  def confirmation_email(user)
    @user = user
    @confirmation_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:5173')}/confirm-email?token=#{@user.confirmation_token}"
    
    mail(
      to: @user.email,
      subject: 'Welcome to Legal Auditor Agent - Please confirm your email'
    )
  end

  def reset_password_email(user)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:5173')}/reset-password?token=#{@user.reset_password_token}"
    
    mail(
      to: @user.email,
      subject: 'Legal Auditor Agent - Reset your password'
    )
  end

  def welcome_email(user)
    @user = user
    @dashboard_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:5173')}/dashboard"
    
    mail(
      to: @user.email,
      subject: 'Welcome to Legal Auditor Agent - Your account is ready!'
    )
  end
end