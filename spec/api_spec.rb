require 'spec_helper'
require 'sinatra'
require 'api/app/app'
require 'rack/test'

describe App do
 include Rack::Test::Methods

  let(:app) { App }
  let(:username) { 'me@example.com' }
  let(:password) { 'password' }
  let(:service) { 'https://app.example.com' }

  before { clear_cookies }

  describe "cold login" do
    it "allows to login" do
      get "/login"
      expect(last_response.status).to eq 200
    end

    it 'provides a login ticket' do
      get '/login'
      expect(last_response.body).to include("<input name='lt' type='hidden' value='LT-")
    end

    it 'it requires a username to be passed in' do
      post '/login', password: password, lt: "LT-random"

      expect(last_response.status).to eq(422)
    end

    it 'requires a password to be passed in' do
      post '/login', username: 'username', lt: "LT-random"
    end

    it 'requires a login ticket to be passed in' do
      post '/login', username: 'username', password: "password"
    end
    
    describe "given a specific user" do
      before do
        @user = spawn_user email: username, password: password
        @login_ticket = spawn_login_ticket
      end

      it 'sends the ticket granting ticket on successfull auth attempt' do
        post 'login', username: username, 
                      password: password, 
                      lt: @login_ticket.name
        expect(rack_mock_session.cookie_jar['CASTGC']).not_to be_nil
      end

      it 'send the service ticket on a successful auth attempt' do
        post "/login", username: username,
                       password: password,
                       lt: @login_ticket.name,
                       service: URI.encode(service)
        expect(last_response.header["Location"]).to match(/(\?|&)ticket=ST-\w+/)
      end

      it 'redirects to a service on a successful auth attempt' do
        post '/login', username: username,
                      password: password,
                      lt: @login_ticket.name,
                      service: URI.encode(service)

        expect(last_response.status).to eq 303
        expect(last_response.header["Location"]).to match(/^#{service}/)
      end
    end
  end
  
  describe "warn login (there is already a ticket granting cookie)" do
    it 'logs a user in base off the cookie' do
      user = spawn_user email: username, password: password
      perform_login user: user, service: "https://app.example.com"
      get '/login', service: 'https://app.example.com'
      expect(last_response.status).to eq 303
    end
  end
end
