defmodule PermissionGroupTest do
  use ExUnit.Case
  doctest Dataservice
  alias Dataservice.Schema.PermissionGroup



  test "create valid objects" do
    assert PermissionGroup.changeset(%PermissionGroup{name: "myGroupName"}).valid?
    refute PermissionGroup.changeset(%PermissionGroup{name: ""}).valid?
  end
end
