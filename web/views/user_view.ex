defmodule Oauth2Server.UserView do
  use Oauth2Server.Web, :view

  def render("index.json", %{user: user}) do
    %{data: render_many(user, Oauth2Server.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Oauth2Server.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{user_id: user.user_id,
      user_name: user.user_name,
      position: user.position,
      number: user.number}
  end
end
