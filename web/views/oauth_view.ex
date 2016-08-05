defmodule Oauth2Server.AuthView do
  use Oauth2Server.Web, :view

  def render("index.json", %{auth: auth}) do
    auth
  end
end
