defmodule OAuthService do

  require Logger
  use OAuth2.Strategy

  alias OAuth2.Strategy.ClientCredentials

  alias OAuth2.AccessToken

  defp config do
    [strategy: ClientCredentials,
     token_url: "/oauth/token"]
  end

  # Public API

  def client do
    Application.get_env(:oauth2_server, AuthConfig)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
  end

  def get_token!(params \\ [], headers \\ []) do
    Logger.debug "token : #{inspect headers}"
    client = put_header(client, "Accept", "application/json")
    client = put_header(client, "authorization", Enum.at(headers, 0))
    Logger.debug "token : #{inspect client}"
    #client = %{client | client_id: "Meg", client_secret: "aaaaa"}
    #OAuth2.Client.get_token(client, [], [])
    #client = %{client | client_id: "", client_secret: ""}
    OAuth2.Client.get_token(client, [], [])
  end

  def get_token(client, params, headers) do
    Logger.debug "token : #{inspect client}"
    client = put_header(client, "Accept", "application/json")
    client = put_header(client, "authorization", Enum.at(params, 0))
    OAuth2.Strategy.ClientCredentials.get_token(client, params, headers)
  end

  def get_oauth_access_token(access_token) do
    Logger.debug "token : #{inspect access_token}"
    {:ok, client} = Exredis.start_link
    retrieved_data = client |> Exredis.query(["GET", "oauth:elixir:" <> access_token])
    Logger.debug "token : #{inspect retrieved_data}"
    token = :erlang.binary_to_term(retrieved_data)
  end  

end
