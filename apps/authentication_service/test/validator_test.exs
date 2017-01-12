defmodule ValidatorTest do
  use ExUnit.Case
  doctest AuthenticationService

    alias Dataservice.Repo
    alias Dataservice.Service.UserService
    alias Dataservice.Schema.Permission
    alias Dataservice.Schema.PermissionGroup
    alias Dataservice.Service.PermissionGroupService
    alias Dataservice.Service.PermissionService
    alias Dataservice.Schema.User
    alias Dataservice.Schema.Token

  test "AuthenticationRequest / Response" do


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
      user = %User{name: Faker.Name.first_name, password: "fdsafdsa", email: "#{Faker.Name.first_name}.#{Faker.Name.last_name}@fdsa"}
      {:ok, inserted_user} = GenServer.call(UserService, {:insert, user})
      {:ok, loaded_user} = GenServer.call(UserService, {:get, inserted_user.id})
      {:ok, user} = GenServer.call(UserService, {:set_permissions, loaded_user, [permission, permission2]})
      alias AuthenticationService.Authenticator
      alias ServiceObjects.AuthenticateRequest
      {:ok, authenticate_response} = GenServer.call(Authenticator, {:authenticate_request, %AuthenticateRequest{username: user.name, password: user.password, token_request_type: "api"}})
      assert authenticate_response.is_authenticated == true
      alias ServiceObjects.ValidateTokenRequest
      validation_request = %ValidateTokenRequest{token: authenticate_response.authentication_token, user_id: user.id}
      {:ok, response} = GenServer.call(AuthenticationService.Validator, {:validate_token, validation_request})
      assert response.is_valid_token
      validation_request = %ValidateTokenRequest{token: "fdsafsafsadf", user_id: user.id}
      {:ok, response} = GenServer.call(AuthenticationService.Validator, {:validate_token, validation_request})
      refute response.is_valid_token
  end

end