defmodule UserTest do
  use ExUnit.Case
  doctest Dataservice
 alias Dataservice.Schema.PermissionGroup
     alias Dataservice.Schema.Permission
      alias Dataservice.Schema.User
      import Ecto.Changeset
  test "create valid object" do

    assert User.changeset(%User{}, %{name: "fdsa", password: "fdsafdsa", email: "fdsa@fdsa"}).valid?
    refute User.changeset(%User{}, %{name: "fdsa", password: "abc", email: "fdsaf@fdsaf.com"}).valid?
    valid_permission_group =  %PermissionGroup{name: "MyPermissionGroup"}
    valid_permission = %Permission{permission_tag: "valid", "permission_group": valid_permission_group}



    user_changeset = %User{} |> User.changeset(%{name: "fdsa", password: "fdsafdsa", email: "fdsa@fdsa"}) |> put_assoc(:permissions, [valid_permission])

    assert user_changeset.valid?

  end
end
