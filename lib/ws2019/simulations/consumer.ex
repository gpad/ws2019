defmodule Ws2019.Simulations.Consumer do
  use GenServer

  # TODO: Create a supervisor for the Simulation Consumer, Receiver

  def start_link(account_id, between, consume_every_msec) do
    GenServer.start_link(__MODULE__, [account_id, between, consume_every_msec])
  end

  def init([account_id, between, consume_every_msec]) do
    tref = Process.send_after(self(), :consume, consume_every_msec)

    state = %{
      account_id: account_id,
      between: between,
      consume_every: consume_every_msec,
      tref: tref
    }

    {:ok, state}
  end

  def handle_info(:consume, state) do
    _ = Process.cancel_timer(state.tref)
    res = consume(state.account_id, state.between)
    _ = IO.puts("Consumer #{self()} - consume from: #{state.account_id} - result: #{res}")
    tref = Process.send_after(self(), :consume, state.consume_every_msec)
    {:noreply, %{state | tref: tref}}
  end

  # rand.uniform 1 =< X =< N
  def consume(account_id, {min, max}) do
    Ws2019.Aggregates.Account.consume(account_id, min - 1 + :rand.uniform(max))
  end
end
