defmodule Dataservice.Schema.Permission do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
    schema "permission" do
        belongs_to :permission_group, Dataservice.Schema.PermissionGroup
        many_to_many :users, Dataservice.Schema.User, join_through: "permissions_to_users"
        field :permission_tag, :string
        timestamps()
    end
    def changeset(permission, params \\ %{}) do
        Logger.debug "changeset execute: #{inspect permission} with params: #{inspect params}"
        permission
        |> cast(params, [:permission_tag])
        |> cast_assoc(:permission_group, is_required: true)
        |> cast_assoc(:users)
        |> validate_required([:permission_tag])
        |> validate_length(:permission_tag, min: 3, max: 15)
    end
end