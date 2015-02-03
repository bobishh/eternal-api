require 'spec_helper'

describe 'Session Requests' do
  let(:admin_email) { "admin@eternalvoid.me" }
  let(:admin_password) { "supersecret" }
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
      it 'saves an admin object-id in a session hash' do
        expect(last_request.session[:user]).to eq(@admin.id)
      end
    end

    context 'invalid credentials' do

      context 'invalid pass' do
        before do
          post '/session/new', { email: admin_email, password: 'shittypass' }
        end
        it "status unauthorized" do responds_with_status 402 end
      end

      context 'invalid email' do
        before do
          post '/session/new', { email: 'shit@shit.com', password: 'shittypass' }
        end
        it "status unauthorized" do responds_with_status 402 end
      end

    end
  end

  after do
    @admin.destroy
  end
end
