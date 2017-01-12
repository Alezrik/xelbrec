defmodule Dataservice.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Dataservice.Worker.start_link(arg1, arg2, arg3)
       supervisor(Dataservice.Repo, []),
       worker(Dataservice.Service.PermissionGroupService, [:ok, [name: Dataservice.Service.PermissionGroupService]]),
       worker(Dataservice.Service.PermissionService, [:ok, [name: Dataservice.Service.PermissionService]]),
       worker(Dataservice.Service.UserService, [:ok, [name: Dataservice.Service.UserService]]),
       worker(Dataservice.Service.TokenService, [:ok, [name: Dataservice.Service.TokenService]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dataservice.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
