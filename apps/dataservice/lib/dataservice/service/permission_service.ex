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
  def handle_call({:refresh_assocs, permission}, _from, state) do
    p = permission
    |> Repo.preload(:permission_group)
    |> Repo.preload(:users)
    {:reply, {:ok, p}, state}
  end
  def handle_call({:insert, item}, _from, state) do
    import Ecto.Changeset
    Logger.debug "checking permission group: #{inspect item.permission_group}"
    alias Dataservice.Schema.PermissionGroup
    refresh_perm_group = PermissionGroup
    |> where(name: ^item.permission_group.name)
    |> Repo.one!
    |> Repo.preload(:permissions)
    #group = PermissionGroup.changeset(item.permission_group, %{})
    change_set = Permission.changeset(%Permission{}, %{permission_tag: item.permission_tag,})
    insert_perm = change_set |> Repo.insert! |> Repo.preload(:permission_group) |> Repo.preload(:users)
    update_change = insert_perm |> Permission.changeset(%{})
      |> put_assoc(:permission_group, refresh_perm_group)
#    |> put_assoc(:permission_group, [p])
#    |> put_assoc(:users, [])
    Logger.debug "create changeset: #{inspect update_change}"
    case change_set.valid? do
      true -> {:reply, Repo.update(update_change), state}
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
    change_set = refresh_item |> Permission.changeset(changemap)
      |> put_assoc(:users, refresh_item.users)
      |> put_assoc(:permission_group, refresh_item.permission_group)
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