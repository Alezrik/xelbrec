defmodule Dataservice.Schema.PermissionGroup do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "permission_group" do
    field :name, :string
    has_many :permissions, Dataservice.Schema.Permission
    timestamps()
  end

  def changeset(permission_group, params \\ %{}) do
    permission_group
    |> cast(params, [:name])
    |> cast_assoc(:permissions)
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 20)
  end
end