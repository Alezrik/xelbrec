defmodule PermissionGroupServiceTest do
  use ExUnit.Case
  doctest Dataservice
  alias Dataservice.Schema.PermissionGroup
  alias Dataservice.Schema.Permission
  alias Dataservice.Schema.User


  test "create valid objects" do
    alias Dataservice.Service.PermissionGroupService
    alias Dataservice.Repo
    Permission
    |> Repo.delete_all
    PermissionGroup
    |> Repo.delete_all
    User
    |> Repo.delete_all
    insert_item = %PermissionGroup{name: "myPermissionGroup"}
    {:ok, _item} = GenServer.call(PermissionGroupService, {:insert, insert_item})
    {:ok, [item]} = GenServer.call(PermissionGroupService, {:get, :all})
    {:ok, item} = GenServer.call(PermissionGroupService, {:get, item.id})
    {:ok, update_item} = GenServer.call(PermissionGroupService, {:update, item, %{name: "newName"}})
    {:ok, item_check} = GenServer.call(PermissionGroupService, {:get, item.id})
    assert update_item.name == item_check.name
    {:ok, _delete_item} = GenServer.call(PermissionGroupService, {:delete, item.id})

  end
end