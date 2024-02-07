require 'bcrypt'
require_relative '../helpers/authentication_helpers'

class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates_format_of :email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'is not a valid email address'
  validates :secret_key, uniqueness: true, allow_nil: true

  def enable_otp
    otp_secret = AuthenticationHelpers.generate_otp_secret
    update(secret_key: otp_secret, two_factor_enabled: true)
    otp_uri = AuthenticationHelpers.generate_otp_uri(self)

    return otp_secret, otp_uri
  end

  def disable_otp
    update(secret_key: nil, two_factor_enabled: false)
  end

  def verify_otp?(otp)
    AuthenticationHelpers.verify_otp?(self.secret_key, otp)
  end
end