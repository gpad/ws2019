defmodule Ws2019.Projections.Recharges do
  use GenServer

  def start_link(id, value) do
    GenServer.start_link(__MODULE__, [id, value], name: :"#{id}")
  end

  def init([id, value]) do
    {:ok, %{id: id, last_action: DateTime.utc_now(), value: value}}
  end

  # TODO: FUNZIONE Wrapper
  # TODO: comandi sync or async ?!?!
  # TODO: Emissione di event ???

  def handle_call(:get_value, _, %{value: value} = state) do
    {:reply, {:ok, value}, %{state | last_action: DateTime.utc_now()}}
  end

  def handle_call({:consume, amount}, _, %{value: value} = state) do
    if value > amount do
      new_value = value - amount
      {:reply, {:ok, new_value}, %{state | value: new_value, last_action: DateTime.utc_now()}}
    else
      {:reply, {:error, :not_enough_money}, %{state | last_action: DateTime.utc_now()}}
    end
  end

  def handle_call({:recharge, amount}, _, %{value: value} = state) do
    new_value = value + amount
    {:reply, {:ok, new_value}, %{state | value: new_value, last_action: DateTime.utc_now()}}
  end
end
