defmodule AuthenticationService.Validator do
  @moduledoc false
  require Logger
  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
  def handle_call({:validate_token, validation_request}, _from, state) do
     token = validation_request.token
     case Guardian.decode_and_verify(token) do
       {:ok, decode_token} ->
            subject = decode_token["sub"]
            user_id = Regex.run(~r/[0-9]*$/, subject)
            Logger.debug "got userid from token: #{inspect Enum.at(user_id, 0)}"
            {:ok, get_user} = GenServer.call(Dataservice.Service.UserService, {:get, String.to_integer(Enum.at(user_id, 0))})
            token = Enum.filter(get_user.tokens, fn x ->
            x.token == token && x.subject == "User:#{validation_request.user_id}" end)
            alias ServiceObjects.ValidateTokenResponse
            response = %ValidateTokenResponse{is_valid_token: Enum.count(token) == 1}
            {:reply, {:ok, response}, state}

       {:error, _msg} ->
        alias ServiceObjects.ValidateTokenResponse
        {:reply, {:ok, %ValidateTokenResponse{}}, state}
    end


  end
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end