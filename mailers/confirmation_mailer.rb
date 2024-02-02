require 'pony'

class ConfirmationMailer
  def self.send_confirmation_email(email)
    subject = 'Registration Successful'
    body = "This email is to confirm your registration"
    puts email
    send_email(email, subject, body)
  end

  private

  def self.send_email(email, subject, body)
    Pony.mail({
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