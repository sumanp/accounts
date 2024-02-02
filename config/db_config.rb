
configure :production do
  db = URI.parse(ENV['DATABASE_URL'])
  set :database, {adapter: 'postgresql',  encoding: 'unicode', database: db.path[1..-1], pool: 2, username: db.user, password: db.password}
end

configure :development do
  set :database, {adapter: 'postgresql',  encoding: 'unicode', database: 'accounts_development', pool: 2, username: 'postgres', password: 'postgres'}
end

configure :test do
  set :database, {adapter: 'postgresql',  encoding: 'unicode', database: 'accounts_test', pool: 2, username: 'postgres', password: 'postgres'}
end