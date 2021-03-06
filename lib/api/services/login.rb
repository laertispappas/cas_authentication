module Api::Services
  class Login
    attr_reader :ticket
    attr_reader :ticket_granting_ticket
    attr_reader :service_ticket
    attr_reader :status
    
    def initialize opts = {}
      @username = opts[:username]
      @password = opts[:password]
      @login_ticket_name = opts[:login_ticket_name]
      @service = opts[:service]
      @ticket_granting_ticket_name = opts[:ticket_granting_ticket_name]
    end

    def call
      # if no username and no ticket is given, generate a login_ticket
      if @username.nil? && @ticket_granting_ticket_name.nil?
        generate_login_ticket
      else
        login
      end
    end


    private

    def generate_login_ticket
      @ticket = LoginTicket.new name: 'LT-#{Digest::SHA1.hexdigest(Time.new.to_s)}'
      @ticket.save
    end
    
    def login
      if valid_auth?
        generate_ticket_granting_ticket
        generate_service_ticket
        @status = :ok
      end

      expire_login_ticket! if @login_ticket_name
    end
    
    def valid_auth?
      # if no ticket present find and return the user from username/passwd
      # else return the user based on ticket provided
      if @ticket_granting_ticket_name.nil?
        @user = User.where(email: @username, encrypted_password: Digest::SHA1.hexdigest(@password)).first
      else
        @ticket_granting_ticket = TicketGrantingTicket.find_by_name(@ticket_granting_ticket_name)
        return false unless @ticket_granting_ticket
        @user = @ticket_granting_ticket.user
      end
    end

    def expire_login_ticket!
      login_ticket = LoginTicket.find_by_name!(@login_ticket_name)
      login_ticket.active = false
      login_ticket.save!
    end

    def generate_ticket_granting_ticket
      @ticket_granting_ticket = TicketGrantingTicket.new(
        name: "TGT-" + Digest::SHA1.hexdigest(Time.new.to_s),
        user: @user)

      @ticket_granting_ticket.save!
    end

    def generate_service_ticket
      @service_ticket = ServiceTicket.new(
        name: "ST-" + Digest::SHA1.hexdigest(Time.new.to_s),
        service: @service,
        user: @user)

      @service_ticket.save!
    end
  end
end
