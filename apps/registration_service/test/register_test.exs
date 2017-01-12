defmodule RegisterTest do
  use ExUnit.Case
  doctest RegistrationService

  test "Register user" do
    alias ServiceObjects.RegisterUserRequest
    alias RegistrationService.Register
    req = %RegisterUserRequest{name: "jack", password: "eightcharacterslong", email: "john@smith.com"}
    {:ok, resp} = GenServer.call(Register, {:register_user, req})
    assert resp.is_registered == true
    req2 = %RegisterUserRequest{name: "jack", password: "abc", email: "john@smith.com"}
    {:ok, resp2} = GenServer.call(Register, {:register_user, req2})
    assert resp2.is_registered == false
  end
end
