require 'mongo_mapper'

class Admin
  include MongoMapper::Document
  key :email, type: String
  key :password_digest, type: String
  many :posts
  many :tokens
  def self.by_email(email)
    admin = Admin.first(email: email)
  end
end

class Post
  include MongoMapper::Document
  key :title, type: String
  key :body, type: String
  key :posted, type: Time
  belongs_to :admin
end

class Token
  include MongoMapper::Document
  key :value, type: String
  key :created, type: Time
  belongs_to :admin
end
