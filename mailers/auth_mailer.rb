require 'pony'

class AuthMailer
  def self.send_confirmation_email(email)
    subject = 'Registration Successful'
    body = "This email is to confirm your registration"
    send_email(email, subject, body)
  end

  def self.send_otp_email(email, topt)
    subject = 'Two-Factor Authentication Code'
    body = "Your one-time code is: #{topt}"
    send_email(email, subject, body)
  end

  private

  def self.send_email(email, subject, body)
    Pony.mail({
      from: 'noreply@arival.com',
      to: email,
      subject: subject,
      body: body,
      via: :smtp,
      via_options: {
        address: ENV['SMTP_SERVER'],
        port: ENV['SMTP_PORT'],
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        authentication: :plain,
        domain: ENV['SMTP_DOMAIN'],
      }
    })
  end
end