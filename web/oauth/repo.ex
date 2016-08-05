defmodule Oauth2Server.Repo do
  use Ecto.Repo, otp_app: :oauth2_server

  import Ecto.Query
  require Logger

  def find_by_application(application_id, secret) do
    Logger.debug "application_id : #{inspect application_id}"
    query = from a in Oauth2Server.Application,
          where: a.application_id == ^application_id,
         select: a
    Repo.all(query)
  end
end
