defmodule Ws2019.Projections.Payments do
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ok = register("money")
    {:ok, %{payments: [], log_event: false}}
  end

  def payments(), do: GenServer.call(__MODULE__, :payments)
  def log_event(value), do: GenServer.cast(__MODULE__, {:log_event, value})

  def handle_call(:payments, _from, state) do
    {:reply, {:ok, state.payments}, state}
  end

  def handle_cast({:log_event, value}, state) do
    {:noreply, %{state | log_event: value}}
  end

  defp handle_event(%{event_id: :payment_accepted} = event, state) do
    log(event, state)
    payments = make_payment_from(event) |> sorted_merge(state.payments)
    {:ok, %{state | payments: payments}}
  end

  defp handle_event(%{event_id: :payment_refused} = event, state) do
    log(event, state)
    payments = make_payment_from(event) |> sorted_merge(state.payments)
    {:ok, %{state | payments: payments}}
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

  defp make_payment_from(%{event_id: :payment_accepted} = event) do
    %{
      result: :acceptd,
      amount: event.payload.consumed,
      current_value: event.payload.current_value,
      executed_at: event.header.emitted_at
    }
  end

  defp make_payment_from(%{event_id: :payment_refused} = event) do
    %{
      result: :refused,
      reason: event.payload.reason,
      current_value: event.payload.current_value,
      executed_at: event.header.emitted_at
    }
  end

  defp sorted_merge(payment, payments) do
    Enum.sort([payment | payments], fn r1, r2 -> r1.executed_at < r2.executed_at end)
  end

  defp log(%{event_id: event_id, aggregate_id: aggregate_id}, %{log_event: true}) do
    Logger.info("[LOGEVENT] Payment #{event_id} for aggregate_id: #{aggregate_id}")
  end

  defp log(_, _), do: :ok
end
