require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv/load'
require 'json'
require 'bcrypt'

require './config/db_config'
require_relative 'models/user'
require_relative 'mailers/auth_mailer'
require_relative 'controllers/registration_controller'
require_relative 'controllers/login_controller'
require_relative 'controllers/settings_controller'

before do
  content_type :json
end

class App < Sinatra::Base
  use RegistrationController
  use LoginController
  use SettingsController
end
