defmodule ServiceObjects.RegisterUserResponse do
  @moduledoc false
  defstruct is_registered: false, errors: [], registered_user: %ServiceObjects.User{}
end