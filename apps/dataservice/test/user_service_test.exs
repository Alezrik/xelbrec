defmodule UserServiceTest do
  use ExUnit.Case
  doctest Dataservice
    alias Dataservice.Schema.PermissionGroup
    alias Dataservice.Schema.Permission
    alias Dataservice.Schema.User
    alias Dataservice.Schema.Token

  test "create valid object" do
    alias Dataservice.Repo
    alias Dataservice.Service.UserService
    Permission
    |> Repo.delete_all
    PermissionGroup
    |> Repo.delete_all
    Token
    |> Repo.delete_all
    User
    |> Repo.delete_all

    user = %User{name: "john", password: "fdsafdsa", email: "fdsa@fdsa"}
    {:ok, _inserted_user} = GenServer.call(UserService, {:insert, user})
    {:ok, [getuser]} = GenServer.call(UserService, {:get, :all})
    {:ok, updateuser} = GenServer.call(UserService, {:update, getuser, %{name: "jane"}})
    {:ok, newupdateduser} = GenServer.call(UserService, {:get, getuser.id})
    assert updateuser.name == newupdateduser.name

    alias Dataservice.Schema.Permission
    alias Dataservice.Schema.PermissionGroup
    alias Dataservice.Service.PermissionGroupService
    alias Dataservice.Service.PermissionService

    valid_permission_group = %PermissionGroup{name: "myPermissionGroup"}
    {:ok, _permission_group} = GenServer.call(PermissionGroupService, {:insert, valid_permission_group})

    permission = %Permission{permission_tag: "test_tag", permission_group: valid_permission_group}
    {:ok, insert_permission} = GenServer.call(PermissionService, {:insert, permission})

    {:ok, _user_with_permissions} = GenServer.call(UserService, {:add_permission, newupdateduser, insert_permission})

    permission2 = %Permission{permission_tag: "test_tag2", permission_group: valid_permission_group}
    {:ok, insert_permission2} = GenServer.call(PermissionService, {:insert, permission2})
    {:ok, _user_with_permissions2} = GenServer.call(UserService, {:add_permission, newupdateduser, insert_permission2})
    {:ok, check_get_user} = GenServer.call(UserService, {:get, getuser.id})
    assert Enum.count(check_get_user.permissions) == 2
    {:ok, _user_remove_permission} = GenServer.call(UserService, {:remove_permission, check_get_user, insert_permission.id})

    {:ok, _deleted_user} = GenServer.call(UserService, {:delete, check_get_user.id})

  end
end
