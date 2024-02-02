require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'
require 'json'
require 'bcrypt'

require './config/db_config'
require_relative 'models/user'

before do
  content_type :json
end

class App < Sinatra::Base

  # Registration
  post '/register' do
    data = JSON.parse(request.body.read)
    user = User.new(email: data['email'], password: data['password'])

    if user.save
      # send_confirmation_email(user.email)
      { message: 'Registration successful. Confirmation email sent.' }.to_json
    else
      status 422
      { error: 'Error during registration. Please try again.' }.to_json
    end
  end

end
