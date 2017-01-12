defmodule AuthorizationService.Authorizer do
  @moduledoc false
  
  use GenServer
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def handle_call({:authorize_request, authorization_request}, _from, state) do
    case Guardian.decode_and_verify(authorization_request.token) do
        {:error, _msg} -> {:reply, {:ok, %ServiceObjects.AuthorizationResponse{}}, state}
        {:ok, decode} ->
            get_permissions_from_claims = Guardian.Permissions.from_claims(decode, authorization_request.permission_group)
            result = Guardian.Permissions.all?(get_permissions_from_claims, authorization_request.permissions_required, authorization_request.permission_group)
            {:reply, {:ok, %ServiceObjects.AuthorizationResponse{is_authorized: result}}, state}
    end
  end
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end