defmodule AuthenticationService.Authenticator do
  @moduledoc false
  
  use GenServer
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  defp generate_claim_group(permission) do
    {:ok, refresh_group} = GenServer.call(Dataservice.Service.PermissionService, {:load_group, permission})
    refresh_group.permission_group.name
  end
  defp insert_user_token(user, generated_token, token_info) do
    Task.Supervisor.start_child(AuthenticationService.Task.Supervisor,
     fn ->
        Logger.debug "Debugging token_info: #{inspect token_info}"
        token_db_entry = %Dataservice.Schema.Token{token: generated_token, expire: token_info["exp"], issue: token_info["iss"], issue_time: token_info["iat"], subject: token_info["sub"], token_type: "api", user: user}
        Logger.debug "Generated serialized token: #{inspect token_db_entry}"
        {:ok, _token} = GenServer.call(Dataservice.Service.TokenService, {:insert, token_db_entry})
      end)
  end

  def handle_call({:authenticate_request, authenticate_request}, _from, state) do
    {:ok, user_result} = GenServer.call(Dataservice.Service.UserService, {:get_user_by_name_password, authenticate_request.username, authenticate_request.password})
    case user_result do
        nil -> {:reply, {:ok, %ServiceObjects.AuthenticateResponse{}}, state}
        user_result ->
        Logger.debug "Generating Token/Claims for #{inspect user_result}"
        exposed_user = %ServiceObjects.User{name: user_result.name, id: user_result.id}
        Logger.debug "Generated user: #{inspect exposed_user}"
        generated_claims = Enum.group_by(user_result.permissions, fn x -> generate_claim_group(x) end, fn x -> x.permission_tag end)
         Logger.debug "Generated claims: #{inspect generated_claims}"
         {:ok, generated_token, token_info} = Guardian.encode_and_sign(exposed_user, :api, perms: generated_claims)
         Logger.debug "Generated token: #{generated_token} for token_info: #{inspect token_info}"
         insert_user_token(user_result, generated_token, token_info)
        {:reply, {:ok, %ServiceObjects.AuthenticateResponse{is_authenticated: true, authentication_token: "#{generated_token}"}}, state}
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end