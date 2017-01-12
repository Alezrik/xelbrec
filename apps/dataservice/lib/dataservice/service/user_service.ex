defmodule Dataservice.Service.UserService do
  @moduledoc false
  
  use GenServer
  import Ecto.Query
  alias Dataservice.Schema.User
  alias Dataservice.Repo

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def handle_call({:insert, user}, _from, state) do
    changeset = User.changeset(%User{}, %{name: user.name, password: user.password, email: user.email})
    case changeset.valid? do
      true -> {:reply, Repo.insert(changeset), state}
      false -> {:reply, {:error, changeset.errors}, state}
    end
  end
  def handle_call({:get, attr}, _from, state) do
    result = case attr do
      :all ->
        User
        |> Repo.all
        |> Repo.preload(:permissions)
        |> Repo.preload(:tokens)
      _id ->
        User
        |> where(id: ^attr)
        |> Repo.one
        |> Repo.preload(:permissions)
        |> Repo.preload(:tokens)

    end
    {:reply, {:ok , result}, state}
  end
  def handle_call({:get_user_by_name_password, username, password}, _from, state) do
    result = User
    |> where(name: ^username)
    |> where(password: ^password)
    |> Repo.one
    case result do
      nil -> {:reply, {:ok, result}, state}
      notnil -> res = notnil
        |> Repo.preload(:permissions) |> Repo.preload(:tokens)
        {:reply, {:ok, res}, state}
    end
  end
  def handle_call({:update, user, usermap}, _from, state) do
    changeset = User.changeset(user, usermap)
    case changeset.valid? do
      true -> {:reply, Repo.update(changeset), state}
      false -> {:reply, {:error, changeset.errors}, state}
    end
  end
  def handle_call({:set_permissions, user, permissions}, _from, state) do
    import Ecto.Changeset
    changeset = user |> User.changeset(%{}) |> put_assoc(:permissions, permissions)
    case changeset.valid? do
          true -> {:reply, Repo.update(changeset), state}
          false -> {:reply, {:error, changeset.errors}, state}
    end
  end
  def handle_call({:add_permission, user, permission}, _from, state) do
    import Ecto.Changeset
    changeset = user |> User.changeset(%{}) |> put_assoc(:permissions, [permission])
    case changeset.valid? do
      true -> {:reply, Repo.update(changeset), state}
      false -> {:reply, {:error, changeset.errors}, state}
    end
  end
  def handle_call({:remove_permission, user, permission_id}, _from, state) do
    import Ecto.Changeset
    changeset = user |> User.changeset(%{}) |> put_assoc(:permissions, Enum.filter(user.permissions, fn x -> x.id != permission_id end))
    case changeset.valid? do
      true -> {:reply, Repo.update(changeset), state}
      false -> {:reply, {:error, changeset.errors}, state}
    end
  end
  def handle_call({:delete, id}, _from, state) do
    response = User
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