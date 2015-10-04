require 'spec_helper'
require 'sinatra'
require 'api/app/app'
require 'rack/test'

describe App do
  include Rack::Test::Methods

  let(:app) { App }
  let(:user) { spawn_user email: 'me@example.com', password: 'password' }
  let(:service) { "https://app.exmaple.com" }

  before do
    clear_cookies
    perform_login user: user, service: service
  end

  it 'validates a service ticket for a service' do
    get "/p3/serviceValidate", service: service, ticket: @service_ticket

    expect(last_response.status).to eq 200
  end

  it 'returns an XML response' do
    get "/p3/serviceValidate", service: service, ticket: @service_ticket
    
    expect(last_response.content_type).to match(%r{application/xml})
  end


end
