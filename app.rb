require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'
require 'json'
require 'bcrypt'

require './config/db_config'
require_relative 'models/user'
require_relative 'mailers/auth_mailer'

helpers AuthenticationHelpers

before do
  content_type :json
end

class App < Sinatra::Base

  # Registration
  post '/register' do
    params = JSON.parse(request.body.read)

    # Check if the email is already registered
    if User.find_by(email: params['email'])
      status 400
      { message: 'Email already registered' }.to_json
    else
      user = User.new(email: params['email'], password: params['password'])

      if user.valid?
        if user.save
          # Send a confirmation email
          AuthMailer.send_confirmation_email(params['email']) #TODO: move to a background job

          { message: 'Registration successful. Please check your email for confirmation.' }.to_json
        else
          status 500
          { message: 'Internal Server Error' }.to_json
        end
      else
        status 400
        { message: 'Validation failed', errors: user.errors.full_messages }.to_json
      end
    end
  end

  # Login route
  post '/login' do
    params = JSON.parse(request.body.read)
    user = User.find_by(email: params['email'])

    if user && User.authenticate(params['password'])
      if user.otp_enabled?
        # Send one-time code to the user's email
        topt = AuthenticationHelpers.generate_otp_now(user)
        AuthMailer.send_otp_email(params['email'], topt) #TODO: move to a background job

        { success: true, message: 'Two-factor authentication code sent. Provide the code to complete login.' }.to_json
      else
        { success: true, message: 'Login successful.' }.to_json
      end
    else
      status 401
      { success: false, message: 'Invalid email or password.' }.to_json
    end
  end

  # Verify one-time code
  post '/verify_otp/:id' do |id|
    user = User.find_by(id: id)
    params = JSON.parse(request.body.read)

    if user&.otp_enabled? && AuthenticationHelpers.verify_otp?(user.otp_secret, params['otp'])
      { success: true, message: 'Two-factor authentication successful. Login complete.' }.to_json
    else
      status 401
      { success: false, message: 'Incorrect or expired two-factor authentication code.' }.to_json
    end
  end

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
