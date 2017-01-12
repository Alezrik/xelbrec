defmodule ServiceObjects.AuthorizationRequest do
  @moduledoc false
  defstruct token: "NOT_VALID_TOKEN", permission_group: "NOP", permissions_required: []
end