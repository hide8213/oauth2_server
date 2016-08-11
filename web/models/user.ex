defmodule Oauth2Server.User do
  use Oauth2Server.Web, :model

  
  @primary_key {:user_id, :string, []}
  @derive {Phoenix.Param, key: :user_id}
  schema "user" do
    field :user_name, :string
    field :email, :string
    field :password, :string
    field :enabled, :integer
    field :inserted_user, :string
    field :updated_user, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :user_name, :email])
    |> validate_required([:user_name])
  end
end
