defmodule Ws2019.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Ws2019.Worker.start_link(arg)
      {Ws2019.Projections.Payments, []},
      {Ws2019.Projections.Recharges, []}
    ]

    {:ok, _} =
      Registry.start_link(
        keys: :duplicate,
        name: :event_dispatcher,
        partitions: System.schedulers_online()
      )

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ws2019.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
