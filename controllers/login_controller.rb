require 'sinatra/base'
require 'json'
require_relative '../models/user'
require_relative '../mailers/auth_mailer'
require_relative '../helpers/authentication_helpers'

class LoginController < Sinatra::Base
  post '/login' do
    params = JSON.parse(request.body.read)
    user = User.find_by(email: params['email'])

    if user && user.authenticate(params['password'])
      if user.two_factor_enabled
        # Send one-time code to the user's email
        topt = AuthenticationHelpers.generate_otp_now(user)
        AuthMailer.send_otp_email(params['email'], topt) #TODO: move to a background job

        { success: true, user_id: user.id, message: 'Two-factor authentication code sent. Provide the code to complete login.' }.to_json
      else
        { success: true, user_id: user.id, message: 'Login successful.' }.to_json
      end
    else
      status 401
      { success: false, message: 'Invalid email or password.' }.to_json
    end
  end

  post '/login/verify_otp/:id' do |id|
    user = User.find_by(id: id)
    params = JSON.parse(request.body.read)

    if user&.two_factor_enabled? && user.verify_otp?(params['otp'])
      { success: true, message: 'Two-factor authentication successful. Login complete.' }.to_json
    else
      status 401
      { success: false, message: 'Incorrect or expired two-factor authentication code.' }.to_json
    end
  end
end