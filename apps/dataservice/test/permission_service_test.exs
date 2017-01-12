defmodule PermissionServiceTest do
  use ExUnit.Case
  doctest Dataservice
  alias Dataservice.Schema.Permission
  alias Dataservice.Service.PermissionGroupService
  alias Dataservice.Schema.PermissionGroup
  alias Dataservice.Schema.Permission
  alias Dataservice.Schema.User
  alias Dataservice.Schema.Token


  test "create valid objects" do
    alias Dataservice.Service.PermissionService
    alias Dataservice.Repo
    Permission
    |> Repo.delete_all
    PermissionGroup
    |> Repo.delete_all
    Token
          |> Repo.delete_all
    User
    |> Repo.delete_all
    valid_permission_group = %PermissionGroup{name: "myPermissionGroup"}
    {:ok, permission_group} = GenServer.call(PermissionGroupService, {:insert, valid_permission_group})

    permission = %Permission{permission_tag: "test_tag", permission_group: permission_group}
    {:ok, _inserted_item} = GenServer.call(PermissionService, {:insert, permission})

    {:ok, [item]} = GenServer.call(PermissionService, {:get, :all})

    {:ok, updated_item} = GenServer.call(PermissionService, {:update, item, %{permission_tag: "SomeOtherName"}})

    {:ok, get_item} = GenServer.call(PermissionService, {:get, item.id})

    assert updated_item.permission_tag == get_item.permission_tag

    {:ok, _deleted_item} = GenServer.call(PermissionService, {:delete, item.id})

  end
end