defmodule ManagerTest do
  use ExUnit.Case
  doctest UserManager
  alias Dataservice.Repo
  alias Dataservice.Schema.Permission
  alias Dataservice.Schema.PermissionGroup
  alias Dataservice.Service.PermissionGroupService
  alias Dataservice.Service.PermissionService
  alias Dataservice.Schema.User
  alias Dataservice.Schema.Token
  test "register user" do
    Permission
    |> Repo.delete_all
    PermissionGroup
    |> Repo.delete_all
   Token
    |> Repo.delete_all
    User
    |> Repo.delete_all
    valid_permission_group = %PermissionGroup{name: "myPermissionGroup"}
    {:ok, _permission_group} = GenServer.call(PermissionGroupService, {:insert, valid_permission_group})
    permission = %Permission{permission_tag: "test_tag", permission_group: valid_permission_group}
    {:ok, _insert_permission} = GenServer.call(PermissionService, {:insert, permission})
    permission2 = %Permission{permission_tag: "test_tag2", permission_group: valid_permission_group}
    {:ok, _insert_permission2} = GenServer.call(PermissionService, {:insert, permission2})
    alias UserManager.Manager
    register_user_params = %{"name" => Faker.Name.first_name, "password" => "fdsafdsa", "email" => "#{Faker.Name.first_name}.#{Faker.Name.last_name}@here.com"}
    {:ok, registered_user} = GenServer.call(Manager, {:register_user, register_user_params})
    import Ecto.Query
    Process.sleep(200)
    item = User
    |> where(id: ^registered_user.registered_user.id)
    |> Repo.one
    |> Repo.preload(:permissions)
    assert Enum.count(item.permissions) == 2

   # Process.sleep(2000)
  end

  test "invalid user creations" do
    Permission
    |> Repo.delete_all
    PermissionGroup
    |> Repo.delete_all
   Token
    |> Repo.delete_all
    User
    |> Repo.delete_all
    valid_permission_group = %PermissionGroup{name: "myPermissionGroup"}
    {:ok, _permission_group} = GenServer.call(PermissionGroupService, {:insert, valid_permission_group})
    permission = %Permission{permission_tag: "test_tag", permission_group: valid_permission_group}
    {:ok, _insert_permission} = GenServer.call(PermissionService, {:insert, permission})
    permission2 = %Permission{permission_tag: "test_tag2", permission_group: valid_permission_group}
    {:ok, _insert_permission2} = GenServer.call(PermissionService, {:insert, permission2})
    alias UserManager.Manager
#        register_user_params = %{"name" => Faker.Name.first_name, "password" => "fdsafdsa", "email" => "#{Faker.Name.first_name}.#{Faker.Name.last_name}@here.com"}

    register_user_params = %{"name" => "a", "password" => "fdsafdsa", "email" => "#{Faker.Name.first_name}.#{Faker.Name.last_name}@here.com"}
    {:error, _errors} = GenServer.call(Manager, {:register_user, register_user_params})
    register_user_params = %{"name" => Faker.Name.first_name, "password" => "fdsa", "email" => "#{Faker.Name.first_name}.#{Faker.Name.last_name}@here.com"}
    {:error, _errors} = GenServer.call(Manager, {:register_user, register_user_params})
    register_user_params = %{"name" => Faker.Name.first_name, "password" => "fdsafdsa", "email" => ""}
    {:error, _errors} = GenServer.call(Manager, {:register_user, register_user_params})

  end

end
