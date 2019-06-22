defmodule Ws2019.Aggregates.Account do
  use GenServer

  def start_link(id, value) do
    GenServer.start_link(__MODULE__, [id, value], name: :"#{id}")
  end

  def init([id, value]) do
    {:ok, %{id: id, last_action: DateTime.utc_now(), value: value}}
  end

  def get_value(id), do: GenServer.call(id, :get_call)

  def consume(id, amount), do: GenServer.call(id, {:consume, amount})
  def recharge(id, amount), do: GenServer.cast(id, {:recharge, amount})

  def handle_call(:get_value, _, %{value: value} = state) do
    {:reply, {:ok, value}, %{state | last_action: DateTime.utc_now()}}
  end

  def handle_cast({:consume, amount}, _from, %{value: value, id: id} = state) do
    if value > amount do
      new_value = value - amount
      :ok = emit(:payment_executed, id, %{consumed: amount, current_value: new_value})
      {:noreply, {:ok, new_value}, %{state | value: new_value, last_action: DateTime.utc_now()}}
    else
      :ok = emit(:payment_refused, id, %{reason: :not_enough_money, current_value: value})
      {:noreply, {:error, :not_enough_money}, %{state | last_action: DateTime.utc_now()}}
    end
  end

  def handle_call({:recharge, amount}, %{value: value, id: id} = state) do
    new_value = value + amount
    emit(:recharged, id, %{reason: :not_enough_money, current_value: value})
    {:noreply, %{state | value: new_value, last_action: DateTime.utc_now()}}
  end

  defp emit(_event, _id, _payload) do
    # TODO: FIX EVENTS!!!
    :ok
  end
end
