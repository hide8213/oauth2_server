defmodule Oauth2Server.AuthController do
  use Oauth2Server.Web, :controller


  require Logger

  def client(conn, _params) do
    authorization = get_req_header(conn, "authorization")
    Logger.debug "authorization : #{inspect authorization}"
    result = OAuthService.get_token!([], authorization)
    case result do
      {:ok, result} -> result
      {:error, error} -> {:error, error}
    end
    Logger.debug "result : #{inspect result}"
    token = elem(result, 1)
    Logger.debug "token : #{inspect token}"
    data = :erlang.term_to_binary(token)

    {:ok, client} = Exredis.start_link

    client |> Exredis.query ["SET", "oauth:elixir:" <> token.access_token, data]
    #json conn, %{ access_token: token.access_token}
    auth = %{access_token: token.access_token, token_type: token.token_type, expires_at: token.expires_at}
    render(conn, "index.json", auth: auth)
  end

  def token(conn, _params) do 
    authorization = Enum.at(get_req_header(conn, "authorization"), 0)
    Logger.debug "authorization : #{inspect authorization}"
    if authorization == nil or String.starts_with? authorization, "Basic " do
      client_auth = get_authorization(authorization)
      Logger.debug "client_auth : #{inspect client_auth}"
    else
      conn
          |> put_resp_content_type("application/json")
          |> send_resp(400, Poison.encode!(%{message: "Not authorized"}))
    end

    case Authenticator.validate(client_auth, _params) do
      {:ok, result} -> 
          auth = %{access_token: result.access_token, token_type: result.token_type, expires_at: result.expires_at}
          render(conn, "index.json", auth: auth)
      {:error, error} -> 
          render(conn, "index.json", auth: error)
    end
  end

  defp get_authorization(authorization) do
    client_auth = Base.decode64(String.slice(authorization, 6, String.length(authorization)))
    Logger.debug "client_auth : #{inspect client_auth}"
    case client_auth do
      {:ok, client_auth} ->
        client_spilt = String.split(client_auth, ":")
        Logger.debug "client_spilt : #{inspect Enum.at(client_spilt, 0)}"
        %{client_id: Enum.at(client_spilt, 0), secret: Enum.at(client_spilt, 1)}
      
      {:error, error} -> {:error, error}
    end
  end

end
