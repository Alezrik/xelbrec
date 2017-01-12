defmodule AuthenticationService.GuardianSerializer do
  @moduledoc false
  @behaviour Guardian.Serializer

    alias ServiceObjects.User

    def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
    def for_token(_), do: {:error, "Unknown resource type"}

    def from_token("User:" <> id) do
        {:ok, db_user} = GenServer.call(Dataservice.Service.UserService, {:get, id})
        {:ok, %User{name: db_user.name, id: db_user.id}}
    end
    def from_token(_), do: {:error, "Unknown resource type"}
  
end