defmodule Ws2019.Simulations.Supervisor do
  use DynamicSupervisor
  alias Ws2019.Simulations.Consumer
  alias Ws2019.Simulations.Recharger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_consumer(account_id, between, consume_every_msec) do
    spec = %{
      id: Consumer,
      start: {Consumer, :start_link, [account_id, between, consume_every_msec]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def start_recharger(account_id, between, consume_every_msec) do
    spec = %{
      id: Recharger,
      start: {Recharger, :start_link, [account_id, between, consume_every_msec]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def how_many_children(), do: DynamicSupervisor.which_children(__MODULE__) |> length

  def how_many_recharger() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.filter(fn {:undefined, _pid, :worker, [module]} -> module == Recharger end)
    |> length
  end

  def how_many_consumer() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.filter(fn {:undefined, _pid, :worker, [module]} -> module == Consumer end)
    |> length
  end

  def stop_all_children() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} ->
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end)
  end
end
