defmodule PermissionTest do
  use ExUnit.Case
  doctest Dataservice
  alias Dataservice.Schema.PermissionGroup
  alias Dataservice.Schema.Permission



  test "create valid objects" do
    valid_permission_group = %PermissionGroup{name: "MyPermissionGroup"}
    assert Permission.changeset(%Permission{permission_tag: "valid", "permission_group": valid_permission_group}, %{}).valid?
    refute Permission.changeset(%Permission{permission_tag: "", "permission_group": valid_permission_group}, %{}).valid?
  end

end