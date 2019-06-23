alias Ws2019.Aggregates.Account
{:ok, id} = Ws2019.Aggregates.Account.start_link(42, 5000)
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

Account.recharge(id, 100)

Ws2019.Projections.Payments.payments()
Ws2019.Projections.Recharges.recharges()
