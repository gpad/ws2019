# > iex --sname ws2019 -S mix
alias Ws2019.Aggregates.Account
{:ok, _pid} = Ws2019.Aggregates.Account.start_link(42, 5000)
id = 42
Account.current_value(id)

Process.whereis(:"42")
Process.whereis(:anti_fraud_42)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()

Account.consume(id, 200)
Account.consume(id, 200)
Account.consume(id, 200)
Account.recharge(id, 100)

Account.current_value(id)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()

Account.consume(id, 200)
Account.consume(id, 200)
Account.consume(id, 200)
Ws2019.Projections.Payments.payments()
Account.current_value(id)

Account.recharge(id, 100)
Account.recharge(id, 100)
Account.recharge(id, 100)
Ws2019.Projections.Recharges.recharges()
Account.current_value(id)

Process.whereis(:"42")
Process.whereis(:anti_fraud_42)

Account.consume(id, 20_000)
Account.consume(id, 200)

Process.whereis(:"42")
Process.whereis(:anti_fraud_42)

Account.consume(id, 20_000)

Process.whereis(:"42")
Process.whereis(:anti_fraud_42)

# ###
# Show the CODE, also the simulation
# ###
@doc """
- Account
- anti_fraud
- projects
- simulations
"""

# restart Account
alias Ws2019.Aggregates.Account
{:ok, _pid} = Ws2019.Aggregates.Account.start_link(42, 5000)
id = 42
Account.current_value(id)

Account.recharge(id, 100)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()

Ws2019.Projections.Payments.log_event(true)

Ws2019.Simulations.Supervisor.start_consumer(42, {100, 300}, :timer.seconds(3))
Ws2019.Simulations.Supervisor.start_recharger(42, {100, 300}, :timer.seconds(5))
Ws2019.Simulations.Supervisor.how_many_children()
Ws2019.Simulations.Supervisor.how_many_consumer()
Ws2019.Simulations.Supervisor.how_many_recharger()

Ws2019.Projections.Recharges.log_event(true)

Ws2019.Projections.Payments.log_event(false)

Process.list |> length

(1..100) |> Enum.each(fn _ ->
  Ws2019.Simulations.Supervisor.start_consumer(42, {100, 300}, :timer.seconds(3))
  Ws2019.Simulations.Supervisor.start_recharger(42, {100, 300}, :timer.seconds(5))
end)

Ws2019.Simulations.Supervisor.how_many_children()

Ws2019.Simulations.Supervisor.stop_all_children()
Ws2019.Simulations.Supervisor.how_many_children()

# Connect to a remote node
# > iex --sname gpad --remsh ws2019@tardis --hidden
Logger.configure level: :warn
Logger.configure level: :info
Ws2019.Simulations.Supervisor.stop_all_children()

Ws2019.Simulations.Supervisor.how_many_children()

# on ws2019
Ws2019.Simulations.Supervisor.how_many_children()
Node.list
