require 'sinatra'
require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'digest'

enable :sessions

#Setup our ORM of database on Sqlite3 model, set dir of DB
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database.db")
#ORM Model of the User table
class User
  include DataMapper::Resource

  property :id,             Serial
  property :email,          String, :required => true
  property :username,           String, :required => true
  property :hashed_password, String, :required => true
  property :created_at,     DateTime
end


#Create or upgrade DB from the ORM Models
DataMapper.auto_upgrade!

get '/' do
  redirect '/welcome'
end

get '/login' do
  if(  User.first(:id => session[:userid]) != nil)
    redirect '/welcome'
  end
  @title = {
    :main => "Welcome!",
    :username => "Login or name of email",
    :password => "Password"
  }
  erb :welcome
end

get '/register' do
   @title = {
    :main => "Welcome!",
    :username => "Login or name of email",
    :password => "Password",
    :check_password => "Repeat of password",
    :mail => "Enter your email"
  }
  erb :register
end

post '/create' do
  username = @params[:newuser][:username]
  mail = @params[:newuser][:mail]
  hashed_password = Digest::MD5.hexdigest(@params[:newuser][:password])
  current_user = User.all(:username => username) | User.all(:email => mail)
  if current_user.length > 0
    redirect '/register'
  end
  @user = User.new();
  @user.hashed_password = hashed_password
  @user.username = username
  @user.email = mail;
  @user.created_at = Time.now
  if @user.save
    redirect("/login");
  end
end

get '/welcome' do
  user = User.first(:id => session[:userid])
  if( user == nil)
    redirect '/login'
  else
    @title = { 
      :main => "Welcome to our service!",
      :username => user.username 
    }
    erb :main
  end
end

post '/auth' do
  username = @params[:session][:username]
  hashed_password = Digest::MD5.hexdigest(@params[:session][:password])

  current_user = User.first(
    :username => username,
    :hashed_password => hashed_password
  )
  #Secure!
  if(current_user != nil)
    session[:userid] = current_user.id
    redirect '/welcome'
  else
    redirect '/login'
  end
end
