require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  validates :email, presence: true, uniqueness: true
  validates_format_of :email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'is not a valid email address'
  validates :password, presence: true, length: { minimum: 6, maximum: 20 }
  validates :secret_key, uniqueness: true, allow_nil: true

  before_save :encrypt_password

  def encrypt_password
    self.password = BCrypt::Password.create(password)
  end

  def authenticate(input_password)
    BCrypt::Password.new(password) == input_password
  end
end