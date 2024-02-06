require 'bcrypt'

class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates_format_of :email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'is not a valid email address'
  validates :secret_key, uniqueness: true, allow_nil: true

  def enable_otp
    otp_secret = AuthenticationHelpers.generate_otp_secret
    self.update(secret_key: otp_secret, two_factor_enabled: true)
    otp_secret
  end
end