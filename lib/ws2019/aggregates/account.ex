defmodule Ws2019.Aggregates.Account do
  use GenServer

  # TODO: Create Supervisro for account

  def start_link(id, value) do
    GenServer.start_link(__MODULE__, [id, value], name: :"#{id}")
  end

  def init([id, value]) do
    {:ok, pid} = Ws2019.Policies.AntiFraud.start_link(id)
    {:ok, %{id: id, last_action: DateTime.utc_now(), value: value, anti_fraud_pid: pid}}
  end

  def current_value(id) when is_atom(id) or is_pid(id), do: GenServer.call(id, :current_value)
  def current_value(id), do: GenServer.call(:"#{id}", :current_value)

  def consume(id, amount) when is_atom(id) or is_pid(id),
    do: GenServer.call(id, {:consume, amount})

  def consume(id, amount), do: GenServer.call(:"#{id}", {:consume, amount})

  def recharge(id, amount) when is_atom(id) or is_pid(id),
    do: GenServer.cast(id, {:recharge, amount})

  def recharge(id, amount), do: GenServer.cast(:"#{id}", {:recharge, amount})

  def block(id, reason) when is_atom(id) or is_pid(id), do: GenServer.cast(id, {:block, reason})
  def block(id, reason), do: GenServer.cast(:"#{id}", {:block, reason})

  def handle_call(:current_value, _from, %{value: value} = state) do
    {:reply, {:ok, value}, %{state | last_action: DateTime.utc_now()}}
  end

  def handle_call({:consume, amount}, _from, %{value: value, id: id} = state) do
    if value > amount do
      new_value = value - amount
      :ok = emit(:payment_accepted, id, %{consumed: amount, current_value: new_value})
      {:reply, {:ok, new_value}, %{state | value: new_value, last_action: DateTime.utc_now()}}
    else
      :ok = emit(:payment_refused, id, %{reason: :not_enough_money, current_value: value})
      {:reply, {:error, :not_enough_money}, %{state | last_action: DateTime.utc_now()}}
    end
  end

  def handle_cast({:recharge, amount}, %{value: value, id: id} = state) do
    new_value = value + amount
    emit(:recharged, id, %{amount: amount, prev_value: value, current_value: new_value})
    {:noreply, %{state | value: new_value, last_action: DateTime.utc_now()}}
  end

  def handle_cast({:block, reason}, %{value: value, id: id} = state) do
    emit(:blocked, id, %{reason: reason, current_value: value})
    {:stop, :normal, state}
  end

  defp emit(event_id, aggregate_id, payload) do
    event = make_event(event_id, aggregate_id, payload)

    Registry.dispatch(:event_dispatcher, "money", fn entries ->
      for {pid, _} <- entries do
        send(pid, {:broad_cast_event, event})
      end
    end)

    :ok
  end

  defp make_event(event_id, aggregate_id, payload) do
    %{
      event_id: event_id,
      aggregate_id: aggregate_id,
      header: %{emitted_at: DateTime.utc_now()},
      payload: payload
    }
  end

  def terminate(_, %{anti_fraud_pid: pid}) do
    GenServer.stop(pid)
  end
end
