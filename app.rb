require 'sinatra'
require 'sinatra/contrib'
require 'json'
require_relative './lib/models/models'
set :environment, :development
class EternalVoidApi < Sinatra::Base
  register Sinatra::Contrib
end

configure do
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "eternal_void_api"
end

helpers do
  def sha2(data)
    Digest::SHA2.new.hexdigest(data)
  end
  def current_admin
    p request.session
    Admin.first(request.session[:user])
  end
end

get '/posts' do
  content_type :json
  status 200
  Post.all.to_json
end

get '/posts/:id' do
  content_type :json
  post = Post.find(params[:id])
  if post != nil
    status 200
    post.to_json
  else
    status 404
  end
end

post '/posts' do
  status 201
  #if current_admin != nil
    #if post = Post.create(body: params[:body], title: params[:title], admin_id: current_admin.id)
      #status 201
      #post.to_json
    #else
      #status 500
    #end
  #else
    #status 402
  #end
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
  else
    status 402
  end
end

