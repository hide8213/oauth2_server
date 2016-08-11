defmodule Oauth2Server.Router do
  use Oauth2Server.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :secured_api do
    plug :fetch_session
    plug :accepts, ["json"]
    plug Oauth2Server.OAuthPlug
  end

  scope "/", Oauth2Server do
    pipe_through :secured_api
    resources "/user", UserController
  end
  scope "/auth", Oauth2Server do
    pipe_through :api
    post "/client", AuthController, :client
    post "/token", AuthController, :token
  end
end
