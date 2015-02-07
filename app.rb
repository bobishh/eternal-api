require 'sinatra'
require 'sinatra/contrib'
require 'json'
require_relative './lib/models'
require_relative './lib/token_generator'
require 'pry'

set :environment, :development
class EternalVoidApi < Sinatra::Base
  register Sinatra::Contrib
  before do
    content_type :json
  end

  register do
    def check(name)
      condition do
        error 401 unless send(name) == true
      end
    end
  end

  configure do
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
    MongoMapper.database = "eternal_void_api"
  end

  helpers do
    def sha2(data)
      Digest::SHA2.new.hexdigest(data)
    end
    def token_fresh?(token)
      three_days = 3*(3600*24)
      token.created_at > Time.now - three_days
    end
    def valid_token?
      user_id = params[:user_id]
      token = params[:token]
      if user_id && token
        admin = Admin.find(user_id)
        token = Token.where(value: token).sort(:created_at.desc).first
        token.admin == admin && token_fresh?(token)
      end
    end
  end

  get '/posts' do
    status 200
    Post.all.to_json
  end

  get '/posts/:id' do
    post = Post.find(params[:id])
    if post != nil
      status 200
      post.to_json
    else
      status 404
    end
  end

  post '/posts', check: :valid_token? do
    post = Post.new(body: params[:body], title: params[:title], admin_id: params[:uid])
    if post.save
      status 201
      post.to_json
    else
      status 500
      "Post not created, #{post.errors}"
    end
  end

  post '/session/new' do
    admin = Admin.by_email(params["email"])
    admin_digest = if admin != nil
                     admin.password_digest
                   end
    login_digest = sha2(params["password"])
    if  admin_digest == login_digest
      request.session[:user] = admin.id
      status 200
      token = Token.new(value: TokenGenerator.generate, admin_id: admin.id, created_at: Time.now)
      token.save
      { token: token }.to_json
    else
      status 401
      "Wrong username/password pair"
    end
  end


end

