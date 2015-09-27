require "spec_helper"

module Api::Services
  describe Signup do
    attr_reader :service

    before do
      @service = Signup.new(email: "me@example.com", password: 'password')
      service.call
    end

    it 'encrypts the password' do
      expect(service.user.encrypted_password.size).to be > 32
    end

    it 'saves the user' do
      expect(service.user.id).to be_present
    end

    it 'has created a timestamp' do
      expect(service.user.created_at).to be < Time.now
    end

    it 'sign a user up' do
      expect(service.status).to eq(:ok)
    end
  end
end

