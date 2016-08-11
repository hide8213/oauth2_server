defmodule Authenticator do

  import Ecto.Query
  require Logger
  alias Oauth2Server.OauthClient
  alias Oauth2Server.User
  alias Oauth2Server.Repo

  # validates request
  def validate(headers, params) do
    if validate_oauth_params(headers, params) === true do
      oauth_client = Repo.get_by!(OauthClient, application_id: headers[:client_id], secret: headers[:secret])
      if oauth_client != nil do
        grant_types = Poison.Parser.parse!(oauth_client.grant_types)
        if Map.has_key?(grant_types, params["grant_type"]) do
          case params["grant_type"] do
            "password" ->
              {:ok, process_password_grant(params, oauth_client)}
            "refresh_token" ->
              {:ok, process_refresh_token_grant(params["refresh_token"], oauth_client)}
            "client_credentials" ->
              {:ok, process_client_credentials_grant(oauth_client)}
            nil ->
              {:error, %{message: "Invalid oauth credentials", code: 400}}
          end
        else
          {:error, %{message: "Invalid oauth credentials", code: 400}}
        end
      else
        {:error, %{message: "Invalid oauth credentials", code: 400}}
      end
    else
       {:error, %{message: "Invalid oauth credentials", code: 400}}
    end
  end

  defp process_client_credentials_grant(oauth_client) do
    case generate_client_credentials_grant(oauth_client) do
      {:ok, resp} ->
        resp
      :error ->
        %{message: "Invalid login credentials", code: 400}
    end
  end

  defp process_refresh_token_grant(refresh_token, oauth_client) do
    if refresh_token != nil do
      case generate_refresh_token_grant(refresh_token, oauth_client) do
        {:ok, resp} ->
          resp
        :error ->
          %{message: "An error has occured. Please try again later", code: 400}
      end
    else
      %{message: "Invalid oauth credentials", code: 400}
    end
  end

  defp process_password_grant(params, oauth_client) do
    if validate_login_params(params) == true do
      case generate_password_grant(params, oauth_client) do
        {:ok, resp} ->
          resp
        :error ->
          %{message: "Invalid login credentials", code: 400}
      end
    else
      %{message: "Invalid login credentials", code: 400}
    end
  end

  def generate_client_credentials_grant(oauth_client) do
    Logger.debug "oauth_client : #{inspect oauth_client}"
    generate_access_token(oauth_client)
    #case generate_access_token(oauth_client, nil) do

        #{:ok, oauth_access_token} ->
          #case generate_refresh_token(oauth_client, oauth_access_token, nil) do
            #{:ok, oauth_refresh_token} ->
              #%{code: 200, access_token: oauth_access_token.access_token, refresh_token: oauth_access_token.access_token, expires_at: oauth_access_token.expires_at}
            #:error -> 
              #%{message: "An error has occured. Please try again later", code: 400}
          #end
        #:error -> 
          #%{message: "An error has occured. Please try again later", code: 400}
      #end
  end

  def generate_refresh_token_grant(refresh_token, oauth_client) do

    {:ok, client} = Exredis.start_link
    retrieved_data = client |> Exredis.query(["GET", "oauth:refresh_token:" <> refresh_token])
    token = :erlang.binary_to_term(retrieved_data)
    Logger.debug "token : #{inspect token}"

    if token != nil do
      
        {:ok, access_token} = generate_access_token(oauth_client)
        generate_refresh_token(oauth_client, access_token)
        {:ok, access_token}

    end


  end

  def generate_password_grant(params, oauth_client) do
    Logger.debug "oauth_client : #{inspect oauth_client}"
    Logger.debug "params : #{inspect params}"
    case validate_user(params["email"], params["password"]) do
      {:ok, user} ->
        Logger.debug "user : #{inspect user}"
        {:ok, access_token} = generate_access_token(oauth_client)
        generate_refresh_token(oauth_client, access_token)
        {:ok, access_token}
        #case generate_access_token(oauth_client, user) do
            #{:ok, oauth_access_token} ->
              #case generate_refresh_token(oauth_client, oauth_access_token, user) do
                #{:ok, oauth_refresh_token} ->
                  #%{code: 200, access_token: oauth_access_token.token, refresh_token: oauth_refresh_token.token, expires_at: oauth_access_token.expires_at}
                #:error -> 
                  #%{message: "An error has occured. Please try again later", code: 400}
              #end
            #:error -> 
              #%{message: "An error has occured. Please try again later", code: 400}
          #end
      _ -> :error
    end
  end

  def generate_access_token(oauth_client) do
    Logger.debug "oauth_client : #{inspect oauth_client}"
    settings = Application.get_env(:oauth2_server, Oauth2Server.Settings)
    Logger.debug "oauth_client : #{inspect oauth_client}"
    expires_at = :os.system_time(:seconds) + settings[:access_token_expiration]
    Logger.debug "expires_at : #{inspect expires_at}"
    token = :crypto.strong_rand_bytes(40) |> Base.url_encode64 |> binary_part(0, 40)
    Logger.debug "token : #{inspect token}"

    auth = %{access_token: token, token_type: "Bearer", expires_at: expires_at}
    
    data = :erlang.term_to_binary(auth)
    {:ok, client} = Exredis.start_link

    client |> Exredis.query ["SET", "oauth:elixir:" <> token, data]
    Logger.debug "auth : #{inspect auth}"
    {:ok, auth}
  end

  def generate_refresh_token(oauth_client, access_token) do
    settings = Application.get_env(:oauth2_server, Oauth2Server.Settings)
    refresh_token_expiration = access_token.expires_at + settings[:refresh_token_expiration]
    token = :crypto.strong_rand_bytes(40) |> Base.url_encode64 |> binary_part(0, 40)
    auth = %{refresh_token: token, token_type: "Bearer", expires_at: refresh_token_expiration}
    data = :erlang.term_to_binary(auth)
    {:ok, client} = Exredis.start_link
    client |> Exredis.query ["SET", "oauth:refresh_token:" <> token, auth]
    Logger.debug "generate_refresh_token : #{inspect auth}"

  end

  # check if account is valid
  def validate_user(email, password) do
    #Repo.start_link
    user = Repo.get_by!(User, email: email)
    Logger.debug "user : #{inspect user}"
    case authenticate(user, password) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  # validate oauth fields
  defp validate_oauth_params(headers, params) do
    if headers[:client_id] != nil and headers[:secret] != nil and params["grant_type"] != nil do
      true
    else
      false
    end
  end

  # validate login fields
  defp validate_login_params(params) do
    if params["email"] != nil and params["password"] != nil do
      true
    else
      false
    end
  end

  # validate user credentials
  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.password)
    end
  end
end