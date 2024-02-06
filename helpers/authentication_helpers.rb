require 'rotp'

module AuthenticationHelpers
  def self.generate_otp_secret
    ROTP::Base32.random_base32
  end

  def self.generate_otp_uri(user)
    totp = ROTP::TOTP.new(user.secret_key, issuer: 'Arival Auth')
    totp.provisioning_uri(user.email)
  end

  def self.generate_otp_now(user)
    totp = ROTP::TOTP.new(user.secret_key, issuer: 'Arival Auth')
    totp.now
  end

  def self.verify_otp?(secret, otp)
    totp = ROTP::TOTP.new(secret, issuer: "Arival Auth")
    result = totp.verify(otp)
    return false if result.nil?
    true
  end
end
