defmodule Dataservice.Repo.Migrations.PermissionGroup do
  use Ecto.Migration

  def change do
    create table(:permission_group) do
      add :name, :string
      timestamps
    end
    create unique_index(:permission_group, [:name])

    create table(:permission) do
      add :permission_tag, :string
      add :permission_group_id, references(:permission_group)
      timestamps
    end
  end
end
