defmodule RelationshipTest do
  use ExUnit.Case

    alias Dataservice.Repo
    alias Dataservice.Service.UserService
    alias Dataservice.Schema.Permission
    alias Dataservice.Schema.PermissionGroup
    alias Dataservice.Service.PermissionGroupService
    alias Dataservice.Service.PermissionService
    alias Dataservice.Schema.User
    alias Dataservice.Schema.Token

  test "a random mix of users with relationships" do

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
        {:ok, insert_permission} = GenServer.call(PermissionService, {:insert, permission})


        permission2 = %Permission{permission_tag: "test_tag2", permission_group: valid_permission_group}
        {:ok, insert_permission2} = GenServer.call(PermissionService, {:insert, permission2})

        permission3 = %Permission{permission_tag: "test_tag3", permission_group: valid_permission_group}
            {:ok, insert_permission3} = GenServer.call(PermissionService, {:insert, permission3})

        permission4 = %Permission{permission_tag: "test_tag4", permission_group: valid_permission_group}
            {:ok, insert_permission4} = GenServer.call(PermissionService, {:insert, permission4})
             permission5 = %Permission{permission_tag: "test_tag5", permission_group: valid_permission_group}
         {:ok, insert_permission5} = GenServer.call(PermissionService, {:insert, permission5})
         permission6 = %Permission{permission_tag: "test_tag6", permission_group: valid_permission_group}
         {:ok, insert_permission6} = GenServer.call(PermissionService, {:insert, permission6})


         users = Enum.map(0..9,
            fn _x -> %User{name: "#{Faker.Name.first_name}", password: "fdsafdsafdsa", email: "#{Faker.Name.first_name}@here.com"} end)

         inserted_users = Enum.map(users, fn x ->
         GenServer.call(UserService, {:insert, x}) end)

         refreshed_users = Enum.map(inserted_users, fn x ->
         {:ok, usr} = x
         GenServer.call(UserService, {:get, usr.id}) end)

         all_permissions = [insert_permission, insert_permission2, insert_permission3, insert_permission4, insert_permission5, insert_permission6]

         _modified_users = Enum.each(refreshed_users, fn x ->
            {:ok, usr} = x
            is_include = :rand.uniform(10)
            user_permissions = Enum.filter(all_permissions, fn _x -> is_include > 5 end)
            GenServer.call(UserService, {:set_permissions, usr, user_permissions})

          end)

        Permission
        |> Repo.delete_all
        PermissionGroup
        |> Repo.delete_all
        Token
        |> Repo.delete_all
        User
        |> Repo.delete_all

  end
end
