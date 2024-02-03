require 'rotp'

module AuthenticationHelpers
  def generate_otp_secret
    ROTP::Base32.random_base32
  end

  def generate_otp_uri(user)
    totp = ROTP::TOTP.new(user.otp_secret, issuer: 'Arival Auth')
    totp.provisioning_uri(user.email, issuer_name: 'Arival Auth')
  end

  def generate_otp_now(user)
    totp = ROTP::TOTP.new(user.otp_secret, issuer: 'Arival Auth')
    totp.now
  end

  def verify_otp(secret, otp)
    totp = ROTP::TOTP.new(secret, issuer: "Arival Auth")
    totp.verify(otp)
  end
end