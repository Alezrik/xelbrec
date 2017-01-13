defmodule Dataservice.Service.PermissionGroupService do
  @moduledoc false

  alias Dataservice.Schema.PermissionGroup
  alias Dataservice.Repo
  import Ecto.Query
  use GenServer

    def start_link(state, opts) do
      GenServer.start_link(__MODULE__, state, opts)
    end

    def init(_opts) do
      {:ok, %{}}
    end
    def handle_call({:insert, permission_group}, _from, state) do
        import Ecto.Changeset
        insert_changeset = %PermissionGroup{} |> PermissionGroup.changeset(%{name: permission_group.name}) |> put_assoc(:permissions, [])
        case insert_changeset.valid? do
           true -> {:reply, Repo.insert(insert_changeset), state}
           false -> {:reply, {:error, insert_changeset.errors}, state}
        end

    end
    def handle_call({:get_by_name, name}, _from, state) do
      result = PermissionGroup
      |> Repo.all
      |> Repo.preload(:permissions)
      {:reply, {:ok, result}, state}
    end
    def handle_call({:get, attr}, _from, state) do
      result = case attr do
        :all ->
            PermissionGroup
            |> Repo.all
            |> Repo.preload(:permissions)
        _id ->
            PermissionGroup
            |> where(id: ^attr)
            |> Repo.one
            |> Repo.preload(:permissions)
      end
      {:reply, {:ok, result}, state}
    end
    def handle_call({:update, old_object, update_map}, _from, state) do
        update_object_change = PermissionGroup.changeset(old_object, update_map)
        case update_object_change.valid? do
          true ->
            update_object = Repo.update(update_object_change)
                    {:reply,  update_object, state}
          false ->
            {:reply, {:error, update_object_change.errors}, state}
        end

    end
    def handle_call({:delete, id}, _from, state) do
      response = PermissionGroup
      |> where(id: ^id)
      |> Repo.one!
      |> Repo.delete
      {:reply, response, state}
    end
    def handle_call(_msg, _from, state) do
      {:reply, :ok, state}
    end

    def handle_cast(_msg, state) do
      {:noreply, state}
    end
  
end