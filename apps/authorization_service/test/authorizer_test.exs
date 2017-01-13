defmodule AuthorizerTest do
  use ExUnit.Case
  doctest AuthorizationService
  alias Dataservice.Repo
  alias Dataservice.Service.UserService
  alias Dataservice.Schema.Permission
  alias Dataservice.Schema.PermissionGroup
  alias Dataservice.Service.PermissionGroupService
  alias Dataservice.Service.PermissionService
  alias Dataservice.Schema.User
  alias Dataservice.Schema.Token
  alias AuthorizationService.Authorizer
  require Logger
  test "validate token permission" do
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
    {:ok, insert_permission} = GenServer.call(PermissionService, {:insert, permission})
    user = %User{name: Faker.Name.first_name, password: "fdsafdsa", email: "#{Faker.Name.first_name}.#{Faker.Name.last_name}@fdsa"}
    {:ok, inserted_user} = GenServer.call(UserService, {:insert, user})
    {:ok, loaded_user} = GenServer.call(UserService, {:get, inserted_user.id})
    Logger.debug "I made it here! #{inspect loaded_user}"
    {:ok, user} = GenServer.call(UserService, {:set_permissions, loaded_user, [insert_permission]})
    alias AuthenticationService.Authenticator
    alias ServiceObjects.AuthenticateRequest
    {:ok, authenticate_response} = GenServer.call(Authenticator, {:authenticate_request, %AuthenticateRequest{username: user.name, password: user.password, token_request_type: "api"}})
    assert authenticate_response.is_authenticated == true
    alias ServiceObjects.AuthorizationRequest
    authorize_request = %AuthorizationRequest{token: authenticate_response.authentication_token, permission_group: "myPermissionGroup", permissions_required: [:test_tag]}
    {:ok, authorize_response} = GenServer.call(Authorizer, {:authorize_request, authorize_request})
    assert authorize_response.is_authorized == true
     authorize_request = %AuthorizationRequest{token: authenticate_response.authentication_token, permission_group: "myPermissionGroup", permissions_required: [:test_tag2]}
    {:ok, authorize_response} = GenServer.call(Authorizer, {:authorize_request, authorize_request})
    assert authorize_response.is_authorized == false

  end
end
