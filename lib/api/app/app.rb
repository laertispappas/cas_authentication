class App < Sinatra::Base
  get "/" do
    @users = User.all
    haml :index
  end

  get "/users/new" do
    haml :signup
  end

  post "/users" do
    service = Api::Services::Signup.new email: params[:user][:email], password: params[:user][:password]
    service.call

    if service.status == :ok
      redirect "/"
    end
  end
end
