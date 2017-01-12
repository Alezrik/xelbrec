defmodule Dataservice.Service.PermissionService do
  @moduledoc false
  
  use GenServer
  alias Dataservice.Schema.Permission
  alias Dataservice.Repo
  import Ecto.Query
  require Logger
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def handle_call({:insert, item}, _from, state) do
    import Ecto.Changeset
    Logger.debug "checking permission group: #{inspect item.permission_group}"
    alias Dataservice.Schema.PermissionGroup
    group = PermissionGroup.changeset(item.permission_group, %{})
    change_set = Permission.changeset(%Permission{}, %{ permission_tag: item.permission_tag})
    |> put_assoc(:permission_group, group)
    |> put_assoc(:users, [])
    Logger.debug "create changeset: #{inspect change_set}"
    case change_set.valid? do
      true -> {:reply, Repo.insert(change_set), state}
      false -> {:reply, {:error, change_set.errors}, state}
    end
  end
  def handle_call({:get, attr}, _from, state) do
    result = case attr do
      :all ->
        Permission
        |> Repo.all
        |> Repo.preload(:permission_group)
       _id ->
        Permission
        |> where(id: ^attr)
        |> Repo.one
        |> Repo.preload(:permission_group)
    end
    {:reply, {:ok, result}, state}
  end
  def handle_call({:load_group, permission}, _from, state) do
    refresh = permission
    |> Repo.preload(:permission_group)
    {:reply, {:ok, refresh}, state}
  end
  def handle_call({:update, item, changemap}, _from, state) do
    import Ecto.Changeset
    refresh_item = item
    |> Repo.preload(:permission_group)
    |> Repo.preload(:users)
    change_set = Permission.changeset(refresh_item, changemap) |> put_assoc(:users, refresh_item.users) |> put_assoc(:permission_group, refresh_item.permission_group)
    case change_set.valid? do
      true ->
        {:reply, Repo.update(change_set), state}
      false -> {:reply, {:error, change_set.errors}, state}
    end
  end

  def handle_call({:delete, id}, _from, state) do
    result = Permission
    |> where(id: ^id)
    |> Repo.one
    |> Repo.delete
    {:reply, {:ok, result}, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end