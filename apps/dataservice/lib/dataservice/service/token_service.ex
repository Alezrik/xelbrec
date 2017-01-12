defmodule Dataservice.Service.TokenService do
  @moduledoc false
  
  use GenServer
  alias Dataservice.Schema.Token
  alias Dataservice.Repo
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def handle_call({:insert, token}, _from, state) do
    import Ecto.Changeset
    alias Dataservice.Schema.User
    token_user = User.changeset(token.user, %{})
    changeset = Token.changeset(%Token{}, %{token: token.token, expire: token.expire,
            issue: token.issue, issue_time: token.issue_time, subject: token.subject, token_type: token.token_type})
            |> put_assoc(:user, token_user)
    case changeset.valid? do
        true -> {:reply, Repo.insert(changeset), state}
        false -> {:reply, {:error, changeset.errors}, state}
    end
  end
  def handle_call({:get, attr}, _from, state) do
    import Ecto.Query
    resp = case attr do
      :all -> Token |> Repo.all |> Repo.preload(:user)
      id -> Token |> where(id: ^id) |> Repo.one |> Repo.preload(:user)
    end
    {:reply, {:ok, resp}, state}
  end
  def handle_call({:get_by_user, user}, _from, state) do
    import Ecto.Query
    alias Dataservice.Schema.User
    resp = User
    |> where(id: ^user.id)
    |> Repo.one
    |> Repo.preload(:tokens)

    {:reply, {:ok, resp.tokens}, state}
  end
  def handle_call({:delete, id}, _from, state) do
    import Ecto.Query
      response = Token
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