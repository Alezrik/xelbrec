defmodule Dataservice.Repo.Migrations.AuthToken do
  use Ecto.Migration

  def change do
    create table(:token) do
        add :token, :string, size: 500
        add :expire, :integer
        add :issue, :string
        add :issue_time, :integer
        add :subject, :string
        add :user_id, references(:user)
        add :token_type, :string

        timestamps()
    end
  end
end
