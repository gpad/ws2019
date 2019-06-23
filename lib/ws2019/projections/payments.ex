defmodule Ws2019.Projections.Payments do
  use GenServer

  # TODO: Remove empty list
  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :ok = register("money")
    {:ok, %{payments: []}}
  end

  def payments(), do: GenServer.call(__MODULE__, :payments)

  # TODO: I should have some old payments
  # def payments(from, to), do: GenServer.call(__MODULE__, {:payments, from, to})

  def handle_call(:payments, _from, state) do
    {:reply, {:ok, state.payments}, state}
  end

  defp handle_event(%{event_id: :payment_accepted} = event, state) do
    payments = make_payment_from(event) |> sorted_merge(state.payments)
    {:ok, %{state | payments: payments}}
  end

  defp handle_event(%{event_id: :payment_refused} = event, state) do
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

  # TODO: create a struct for payments?!
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
end
