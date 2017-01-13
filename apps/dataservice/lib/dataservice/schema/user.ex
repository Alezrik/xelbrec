defmodule Dataservice.Schema.User do
  @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

      schema "user" do
        many_to_many :permissions, Dataservice.Schema.Permission, join_through: "permissions_to_users", on_replace: :delete
        has_many :tokens, Dataservice.Schema.Token
        field :name, :string
        field :email, :string
        field :password, :string
        timestamps()
      end
      def changeset(user, params \\ %{}) do
        user
        |> cast(params, [:name, :email, :password])
        |> cast_assoc(:permissions)
        |> validate_required([:name, :email, :password])
        |> validate_length(:name, min: 2, max: 50)
        |> validate_length(:password, min: 6, max: 50)
        |> validate_length(:email, min: 3, max: 50)
        |> unique_constraint(:name)
        |> unique_constraint(:email)
      end


end