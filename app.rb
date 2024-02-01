require 'sinatra'
require 'sinatra/activerecord'
require 'json'

require './config/db_config'
require './models/user'

# Sinatra configuration
configure do
  enable :sessions
end

class App < Sinatra::Base
  
  # Sample route
  get '/' do
    content_type :json
    { message: 'Hello World!' }.to_json
  end

end
