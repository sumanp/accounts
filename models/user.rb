require 'bcrypt'
require_relative '../helpers/authentication_helpers'

class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates_format_of :email, with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'is not a valid email address'
  validates :secret_key, uniqueness: true, allow_nil: true
end