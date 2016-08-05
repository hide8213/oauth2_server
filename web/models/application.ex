defmodule Oauth2Server.OauthClient do
  use Ecto.Schema, :model
  import Ecto.Changeset

  @primary_key {:application_id, :string, []}
  schema "oauth_client" do
    field :secret, :string
    field :scopes, :string
    field :grant_types, :string
    field :redirect_uri, :string
    field :description, :string
    field :enabled, :string
    field :inserted_user, :string
    field :updated_user, :string

    timestamps
  end

  @required_fields ~w(application_id secret grant_types)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
