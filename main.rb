require 'json'
require 'jwt'
require 'sinatra/base'

class JwtAuth
  def initialize app
    @app = app
  end

  def call env
    begin
      options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
      #bearer = env.fetch('HTTP_AUTHORIZATION','token').slice(7..-1)
      bearer = env.fetch("rack.session.unpacked_cookie_data")["token"][1..-2]

      payload, header = JWT.decode bearer, ENV['JWT_SECRET'], true, options
      p "payload #{payload}\n header #{header}"
      env[:scopes] = payload['scopes']
      env[:user] = payload['user']
      @app.call env
    rescue JWT::DecodeError
      [401, { 'Content-Type' => 'text/plain' }, ['A token must be passed.']]
    rescue JWT::ExpiredSignature
      [403, { 'Content-Type' => 'text/plain' }, ['The token has expired.']]
    rescue JWT::InvalidIssuerError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid issuer.']]
    rescue JWT::InvalidIatError
      [403, { 'Content-Type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
    end
  end
end

class Api < Sinatra::Base
 enable :sessions
  use JwtAuth

  def initialize
    super
    @accounts = {
      tomd: 10000,
      mark: 50000,
      trav: 1000000000
    }
  end

  get '/money' do
    scopes, user = request.env.values_at :scopes, :user
    username = user['username'].to_sym
    if scopes.include?('view_money') && @accounts.has_key?(username)
      content_type :json
      { money: @accounts[username]}.to_json
    else
      halt 403
    end
  end

end

class Public < Sinatra::Base
  enable :sessions

  def initialize
    super
    @logins = {
      tomd: 'abc',
      mark: 'therockshow',
      trav: 'whatsmyageagain'
    }
  end


  get '/' do
    erb :index
  end
  post '/login' do
    username = params[:username]
    password = params[:password]

    if @logins[username.to_sym] == password
      content_type :json
       session[:token] = (token(username)).to_json
       redirect '/api/money'
    else
      halt 401
    end
  end

  def token username
    JWT.encode payload(username),ENV['JWT_SECRET'], 'HS256'
  end

  def payload username
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: ['add_money','remove_money','view_money'],
      user: {
        username: username
      }
    }
  end
end
