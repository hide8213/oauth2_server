defmodule Oauth2Server.OAuthPlug do
  import Plug.Conn

  require Logger
  def init(default), do: default

  def call(conn, default) do
    authorization = Enum.at(get_req_header(conn, "authorization"), 0)
    Logger.debug "authorization : #{inspect authorization}"
    case String.contains? String.upcase(authorization), "BEARER" do
      false ->
        conn
          |> put_resp_content_type("application/json")
          |> send_resp(400, Poison.encode!(%{message: "Error Token Type"}))
      true ->
        Logger.debug "token : #{inspect authorization }"
        oauth_access_token = OAuthService.get_oauth_access_token(Enum.at(String.split(authorization, " "), 1));
    end

    case oauth_access_token do
      nil ->
        conn
          |> put_resp_content_type("application/json")
          |> send_resp(400, Poison.encode!(%{message: "Not authorized"}))
      _ ->
        case oauth_access_token.access_token do
          nil -> 
            conn
              |> put_resp_content_type("application/json")
              |> send_resp(400, Poison.encode!(%{message: "Not authorized"}))
          _ -> 
            put_session(conn, :access_token, oauth_access_token.access_token)
        end
    end
  end

end