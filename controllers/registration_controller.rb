require 'sinatra/base'
require 'json'
require_relative '../models/user'
require_relative '../mailers/auth_mailer'

class RegistrationController < Sinatra::Base
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
end