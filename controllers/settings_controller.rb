require 'sinatra/base'
require 'json'
require_relative '../models/user'

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
      { success: false, message: 'Invalid current password or user_id.' }.to_json
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
        otp_secret, otp_uri = user.enable_otp
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
        user.disable_otp
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