defmodule Ws2019.Projections.Recharges do
  use GenServer

  # TODO: Remove empty list
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ok = register("money")
    {:ok, %{recharges: []}}
  end

  def recharges(), do: GenServer.call(__MODULE__, :recharges)

  def handle_call(:recharges, _from, state) do
    {:reply, {:ok, state.recharges}, state}
  end

  defp handle_event(%{event_id: :recharged} = event, state) do
    recharges = make_recharge_from(event) |> sorted_merge(state.recharges)
    {:ok, %{state | recharges: recharges}}
  end

  defp handle_event(_event, state), do: {:ok, state}

  defp register(topic) do
    {:ok, _} = Registry.register(:event_dispatcher, topic, [])
    :ok
  end

  def handle_info({:broad_cast_event, event}, state) do
    {:ok, new_state} = handle_event(event, state)
    {:noreply, new_state}
  end

  # TODO: create a struct for recharges
  defp make_recharge_from(%{event_id: :recharged} = event) do
    %{
      current_value: event.payload.current_value,
      recharged_of: event.payload.amount,
      recharged_at: event.header.emitted_at
    }
  end

  defp sorted_merge(recharge, recharges) do
    Enum.sort([recharge | recharges], fn r1, r2 -> r1.recharged_at < r2.recharged_at end)
  end
end
