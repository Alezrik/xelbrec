defmodule Dataservice.Schema.Token do
  @moduledoc false
   use Ecto.Schema
      import Ecto.Changeset

        schema "token" do
            field :token, :string
            field :expire, :integer
            field :issue, :string
            field :issue_time, :integer
            field :subject, :string
            field :token_type, :string
            belongs_to :user, Dataservice.Schema.User

            timestamps()
        end

        def changeset(token, params \\ %{}) do
            token
            |> cast(params, [:token, :expire, :issue, :issue_time, :subject, :token_type])
            |> cast_assoc(:user)
            |> validate_required([:token, :expire, :issue, :issue_time, :subject, :token_type])
        end
  
end