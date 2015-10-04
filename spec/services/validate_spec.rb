require 'spec_helper'

module Api::Services
  describe Validate do
    let(:service) { 'https://app.example.com' }
    let(:user) { spawn_user }
    let(:service_ticket) { spawn_service_ticket service: service, user: user }
    let(:validate_service) { Validate.new(service, service_ticket.name) }

    before { validate_service.call }

    it 'should validate a service ticket against a ticket' do
      expect(validate_service.status).to eq :ok
    end

    it 'should return the user\'s info on success validation' do
      expect(validate_service.user).to be_kind_of User
      expect(validate_service.user).to eq user
    end
  end
end
