require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'accounts_development',
  username: 'postgres',
  password: 'postgres',
  host: 'localhost'
)