defmodule Dataservice.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:user) do
        add :name, :string
        add :email, :string
        add :password, :string
        timestamps()
    end
    create unique_index(:user, :name)
    create unique_index(:user, :email)
    create table(:permissions_to_users, primary_key: false) do
        add :user_id, references(:user, on_delete: :delete_all)
        add :permission_id, references(:permission, on_delete: :delete_all, on_update: :update_all)
    end

  end
end
