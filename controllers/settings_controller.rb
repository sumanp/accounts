require 'sinatra/base'
require 'json'
require_relative '../models/user'
require_relative '../helpers/authentication_helpers'

helpers AuthenticationHelpers

class SettingsController < Sinatra::Base
  # Change user password
  put '/settings/change_password/:id' do |id|
    params = JSON.parse(request.body.read)
    user = User.find_by(id: id)

    if user && user.authenticate(params['current_password'])
      user.update(password: params['new_password'])
      { success: true, message: 'Password updated successfully.' }.to_json
    else
      status 401
      { success: false, message: 'Invalid current password.' }.to_json
    end
  end

  # Enable two-factor authentication and provide secret key (QR code)
  put '/settings/enable_otp/:id' do |id|
    user = User.find_by(id: id)

    # Check if two-factor authentication is already enabled
    if user.present?
      if user.two_factor_enabled
        { success: false, message: 'Two-factor authentication is already enabled.' }.to_json
      else
        otp_secret = AuthenticationHelpers.generate_otp_secret
        user.update(secret_key: otp_secret, two_factor_enabled: true)

        # Generate QR code URI
        otp_uri = AuthenticationHelpers.generate_otp_uri(user)

        # Return the secret key and QR code URI to the user
        { success: true, message: 'Two-factor authentication enabled.',
          otp_secret: otp_secret, otp_uri: otp_uri }.to_json
      end
    else
      status 404
      { success: false, message: 'User not found.' }.to_json
    end
  end

  # Disable two-factor authentication
  put '/settings/disable_otp/:id' do |id|
    user = User.find_by(id: id)

    # Check if two-factor authentication is already disabled
    if user.present?
      if user.two_factor_enabled
        user.update(secret_key: nil, two_factor_enabled: false)
        { success: true, message: 'Two-factor authentication disabled.' }.to_json
      else
        { success: false, message: 'Two-factor authentication is already disabled.' }.to_json
      end
    else
      status 404
      { success: false, message: 'User not found.' }.to_json
    end
  end
end