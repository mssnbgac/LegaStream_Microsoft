class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL', 'noreply@legalauditor.com')
  layout 'mailer'
end