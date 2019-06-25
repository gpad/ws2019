alias Ws2019.Aggregates.Account
{:ok, _pid} = Ws2019.Aggregates.Account.start_link(42, 5000)
id = 42
Account.current_value(id)

Process.whereis(:"42")
Process.whereis(:anti_fraud_42)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()

Account.consume(id, 200)
Account.recharge(id, 100)

Account.current_value(id)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()

Account.consume(id, 200)
Account.consume(id, 20_000)

Process.whereis(:"42")
Process.whereis(:anti_fraud_42)

Account.recharge(id, 100)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()

Ws2019.Projections.Payments.log_event(true)

Ws2019.Simulations.Consumer.start_link(42, {100, 300}, :timer.seconds(3))
Ws2019.Simulations.Recharger.start_link(42, {100, 300}, :timer.seconds(6))

Ws2019.Projections.Recharges.log_event(true)

Ws2019.Projections.Payments.log_event(false)
