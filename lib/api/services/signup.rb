module Api::Services
  class Signup
    attr_reader :email, :user, :status

    def initialize email: nil, password: nil
      @email = email
      @password = password

    end
    
    # TODO: Generate more secure digest with salt or something
    def call
      @user = User.new email: @email
      @user.encrypted_password = Digest::SHA1.hexdigest @password
      
      if @user.save
        @status = :ok
      end
    end
  end
end
