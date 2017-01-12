defmodule RegistrationService.Register do
  @moduledoc false
  
  use GenServer
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def handle_call({:register_user, registration_request}, _from, state) do
    alias Dataservice.Service.UserService
    alias ServiceObjects.RegisterUserResponse
    user = %Dataservice.Schema.User{name: registration_request.name, password: registration_request.password, email: registration_request.email}
    Logger.debug "User: #{inspect user}"
    case GenServer.call(UserService, {:insert, user}) do
        {:ok, inserted_user} ->
            Logger.debug "Inserted User: #{inspect inserted_user}"
        {:reply, {:ok, %RegisterUserResponse{ is_registered: true}}, state}
        {:error, errors} ->
            Logger.debug "Errors: #{inspect errors}"
         {:reply, {:ok, %RegisterUserResponse{errors: errors}}, state}
    end

  end
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end