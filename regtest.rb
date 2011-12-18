require 'sinatra'
require 'rubygems'
require 'dm-core'
require 'dm-migrations'

get '/' do
  @title = "Welcome!"
  @login_title = "Login or name of email"
  @password_title = "Password"
  erb :welcome
end

post '/login' do

end
