require "spec_helper"

module Api::Services
  describe Login do
    let(:user) { spawn_user }

    it 'generates a login ticket for a fresh login attempt' do
      service = Login.new
      service.call

      expect(service.ticket).to be_kind_of(LoginTicket)
    end


    it 'logs a user in based off an existing session' do
      ticket_granting_ticket = spawn_ticket_granting_ticket user
      service = Login.new(
        ticket_granting_ticket_name: ticket_granting_ticket.name,
        service: 'https://app.example.com'
      )
      service.call

      expect(service.status).to eq :ok
    end


    it 'provides a service ticket based off a ticket granting cookie auth attempt' do
      ticket_granting_ticket = spawn_ticket_granting_ticket user
      service = Login.new(
        ticket_granting_ticket_name: ticket_granting_ticket.name,
        service: 'https://app.example.com'
      )
      service.call

      expect(service.service_ticket).to be_kind_of ServiceTicket
    end

    describe "Given an existing login ticket" do
      attr_reader :login_ticket

      before do
        @login_ticket = spawn_login_ticket
      end

      it "expires a login ticket after unsuccessful auth attempt" do
        lt_name = login_ticket.name

        service = Login.new(
          username: 'bad_user',
          password: 'bad_password',
          login_ticket_name: lt_name,
          service: 'https://app.example.com'
        )

        service.call

        expect(login_ticket.reload).not_to be_active
      end

      it "generates a ticket granting ticket after a successful auth attempt" do
        lt = login_ticket.name

        service = Login.new(
          username: user.email,
          password: 'password',
          login_ticket_name: lt,
          service: 'https://app.example.com'
        )

        service.call
        expect(service.ticket_granting_ticket).to be_kind_of TicketGrantingTicket
      end

      it "generates a service ticket after a successful auth attempt" do
        lt_name = login_ticket.name
        
        service = Login.new(
          username: user.email,
          password: 'password',
          login_ticket_name: lt_name,
          service: 'https://app.example.com'
        )

        service.call
        expect(service.service_ticket).to be_kind_of ServiceTicket
      end
    end

  end
end
