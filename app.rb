require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'
require 'json'
require 'bcrypt'

require './config/db_config'
require_relative 'models/user'
require_relative 'mailers/confirmation_mailer'

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
      User.create(email: params['email'], password: params['password'])

      # Send a confirmation email
      ConfirmationMailer.send_confirmation_email(params['email']) #TODO: move to a background job

      { message: 'Registration successful. Please check your email for confirmation.' }.to_json
    end
  end

end
