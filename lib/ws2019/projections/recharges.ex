defmodule Ws2019.Projections.Recharges do
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ok = register("money")
    {:ok, %{recharges: [], log_event: false}}
  end

  def recharges(), do: GenServer.call(__MODULE__, :recharges)
  def log_event(value), do: GenServer.cast(__MODULE__, {:log_event, value})

  def handle_call(:recharges, _from, state) do
    {:reply, {:ok, state.recharges}, state}
  end

  def handle_cast({:log_event, value}, state) do
    {:noreply, %{state | log_event: value}}
  end

  defp handle_event(%{event_id: :recharged} = event, state) do
    _ = log(event, state)
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

  defp make_recharge_from(%{event_id: :recharged} = event) do
    %{
      current_value: event.payload.current_value,
      recharged_of: event.payload.amount,
      recharged_at: event.header.emitted_at,
      aggregate_id: event.aggregate_id
    }
  end

  defp sorted_merge(recharge, recharges) do
    Enum.sort([recharge | recharges], fn r1, r2 ->
      DateTime.compare(r1.recharged_at, r2.recharged_at) == :lt
    end)
  end

  defp log(%{aggregate_id: aggregate_id} = event, %{log_event: true}) do
    Logger.info(
      "[LOGEVENT] Recharge executed of #{event.payload.amount} for aggregate_id: #{aggregate_id} curent value: #{
        event.payload.amount
      }"
    )
  end

  defp log(_, _), do: :ok
end
