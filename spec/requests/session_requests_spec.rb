require 'spec_helper'

describe 'Session Requests' do
  let(:admin_email) { "admin@eternalvoid.me" }
  let(:admin_password) { "supersecret" }
  let(:token_value) { "asdlka12312oi3jkasdaksjd1928uhka" }
  let(:admin_password_digest) { Digest::SHA2.new.hexdigest(admin_password)}

  before do
    @admin = Admin.new(email: admin_email, password_digest: admin_password_digest)
    @admin.save
  end

  describe 'POST /session/new' do

    context 'valid credentials' do
      before do
        post '/session/new', { email: admin_email, password: admin_password }
      end
      it "status ok" do responds_with_status 200 end
      it "returns token with string value" do
        expect(json_body["token"]["value"]).to be_kind_of(String)
      end
      it "and admin_id is current admin's id" do
        expect(json_body["token"]["admin_id"]).to eq @admin.id.to_s
      end
    end

    context 'invalid credentials' do

      context 'invalid pass' do
        before do
          post '/session/new', { email: admin_email, password: 'shittypass' }
        end
        it "status unauthorized" do responds_with_status 401 end
      end

      context 'invalid email' do
        before do
          post '/session/new', { email: 'shit@shit.com', password: 'shittypass' }
        end
        it "status unauthorized" do responds_with_status 401 end
      end

    end
  end

  after do
    @admin.destroy
    Token.destroy_all
  end
end
