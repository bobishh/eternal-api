require "spec_helper"
require 'pry'

describe "Posts Requests" do
  let(:admin_email) { "admin@eternalvoid.me" }
  let(:admin_password) { "supersecret" }
  let(:admin_password_digest) { Digest::SHA2.new.hexdigest(admin_password)}
  let(:post_body) { %Q{a #{"long, "*10} time ago in a galaxy #{"far, "*10} away ...} }
  let(:size) { 10 }

  #{{{ get requests
  context "getting posts" do
    before do
      @admin = Admin.new(email: admin_email, password_digest: admin_password_digest)
      @posts = (1..10).map { Post.new(title: rand(120).to_s, body: post_body, admin_id: @admin.id) } 
      @posts.each &:save
      @post = @posts[0]
    end
    describe "GET /posts" do
      before do
        get "/posts", format: :json
      end
      it "status ok" do responds_with_status 200 end

      it "returns json" do responds_with_json end

      it "lists all posts" do
        expect(JSON.parse(last_response.body).size).to eq(size)
      end

    end
    describe "GET /posts/:id" do
      before do
        get "/posts/#{@post.id}", format: :json
      end
      it "status ok" do responds_with_status 200 end

      it "returns json" do responds_with_json end

          end
  end
  #}}}

  #{{{ post requests
  describe "POST /posts" do
    context "admin signed in" do
      before do
        @admin = Admin.new(email: admin_email, password_digest: admin_password_digest)
        @admin.save
        @token = Token.new(value: TokenGenerator.generate, created_at: Time.now, admin_id: @admin.id)
        @token.save
        post "/posts", { body: post_body, title: rand(120).to_s, token: @token.value, user_id: @admin.id.to_s }
      end
      it "status created" do responds_with_status 201 end
      it "responds with created post json" do
        expect(json_body["body"]).to eq(post_body)
      end
      it "saves post in db" do
        expect(Post.where(body: post_body).first.body).to eq(post_body)
      end
    end
    context "admin not signed in" do
      before { post "/posts", { body: post_body, title: rand(120).to_s } }
      it "status unauthorized" do responds_with_status 401 end
    end
  end
  #}}} 

  after do
    Post.destroy_all
    Admin.destroy_all
    Token.destroy_all
  end
end
