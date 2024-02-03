require 'sinatra/base'
require 'json'
require_relative '../models/user'
require_relative '../mailers/auth_mailer'

class SettingsController < Sinatra::Base
    # Change user password
  put 'settings/change_password/:id' do |id|
    params = JSON.parse(request.body.read)
    user = User.find_by(id: id)

    if user && User.authenticate(params['current_password'])
      user.update(password: params['new_password'])
      { success: true, message: 'Password updated successfully.' }.to_json
    else
      status 401
      { success: false, message: 'Invalid current password.' }.to_json
    end
  end

  # Enable two-factor authentication and provide secret key (QR code)
  put 'settings/enable_otp/:id' do |id|
    user = User.find_by(id: id)

    # Check if two-factor authentication is already enabled
    if user.otp_enabled?
      json success: false, message: 'Two-factor authentication is already enabled.'
    else
      otp_secret = AuthenticationHelpers.generate_otp_secret
      user.update(otp_secret: otp_secret)

      # Generate QR code URI
      otp_uri = AuthenticationHelpers.generate_otp_uri(user)

      # Return the secret key and QR code URI to the user
      { success: true, message: 'Two-factor authentication enabled.',
        otp_secret: otp_secret, otp_uri: otp_uri }.to_json
    end
  end

  # Disable two-factor authentication
  put 'settings/disable_otp/:id' do |id|
    user = User.find_by(id: id)

    # Check if two-factor authentication is already disabled
    if user.otp_enabled?
      user.update(otp_secret: nil, otp_code: nil)
      { success: true, message: 'Two-factor authentication disabled.' }.to_json
    else
      { success: false, message: 'Two-factor authentication is already disabled.' }.to_json
    end
  end
end