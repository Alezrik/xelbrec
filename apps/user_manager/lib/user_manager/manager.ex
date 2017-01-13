defmodule UserManager.Manager do
  @moduledoc false
  
  use GenServer
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  defp set_user_permission(user, permission) do
    {:ok, p} = GenServer.call(Dataservice.Service.PermissionService, {:refresh_assocs, permission})
    user_permissions = [p | user.permissions]
    user = GenServer.call(Dataservice.Service.UserService, {:set_permissions, user, user_permissions})
  end

  defp configure_user_background(response) do
    Task.Supervisor.async_nolink(UserManager.Task.Supervisor, fn ->
                {:ok, user} = GenServer.call(Dataservice.Service.UserService, {:get, response.registered_user.id})
                Enum.each(default_registered_user_permissions(), fn permission_set ->
                 {permission_group, permissions} = permission_set
                    {:ok, [perm_group]} = GenServer.call(Dataservice.Service.PermissionGroupService, {:get_by_name, permission_group})
                    permissions_to_add = Enum.filter(perm_group.permissions, fn x ->
                    Enum.member?(permissions, x.permission_tag) end)
                    Enum.each(perm_group.permissions, fn permission ->
                      set_user_permission(user, permission)
                     end)
                 end)
                {:register_complete, response.registered_user}
            end)
  end

  def handle_call({:register_user, params}, _from, state) do
    alias ServiceObjects.RegisterUserRequest
    alias RegistrationService.Register
   response = case GenServer.call(Register, {:register_user, %RegisterUserRequest{name: params["name"], password: params["password"],
        email: params["email"]}}) do
     {:ok, response} -> case response.is_registered do
       false -> {:error, response.errors}

       true ->
        configure_user_background(response)

       {:ok, response}
     end

    end
    Logger.debug "Register user response: #{inspect response}"
    {:reply, response, state}
  end
  defp default_registered_user_permissions() do
    [{"myPermissionGroup", ["test_tag", "test_tag2"]}]
  end
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
  def handle_info({:DOWN, _, :process, pid, _}, state) do
    Logger.debug "state: #{inspect state}"
    {:noreply, state}
  end
  def handle_info({task, {:register_complete, user}}, state) do
    Logger.debug "register complete for #{inspect user}"
    {:noreply, state}
  end
end