i = 1
j = 2
s = "kahfahflas"
a = :a
l = [1, 2, 3]
t = {"gino", 4, :a}
tt = {:a, 2}
kw = [{:opt1, 44}, {:opt3, true}]
kw1 = [opt1: 44, opt3: true]
kw == kw1

m = %{"s" => 2}
m = %{:a => 2}
m = %{a: 2}
m = %{a: 2, c: 3, d: 4}
m1 = %{:a => 2, :c => 3, :d => 4}
m == m1

l = [1, 2, 3]
[x, y, z] = l
[h | t] = l
h
t

m
%{a: v} = m
v
2
%{z: v} = m

f = fn x, y -> x + y end
f
f.(1, 2)
f.(3, 3)
f.(1)

l = [1, 2, 3, 5, 6, 7, 8, 9, 10]
l1 = Enum.map(l, fn x -> x * 3 end)
l2 = Enum.filter(l1, fn x -> rem(x, 2) == 0 end)
sum = Enum.reduce(l2, fn x, acc -> x + acc end)
sum

1..10
|> Enum.map(fn x -> x * 3 end)
|> Enum.filter(fn x -> rem(x, 2) == 0 end)
|> Enum.reduce(fn x, acc -> x + acc end)

1..10 |> Enum.map(&(&1 * 3)) |> Enum.filter(&(rem(&1, 2) == 0)) |> Enum.reduce(&(&1 + &2))

1..10
|> Enum.map(&(&1 * 3))
|> IO.inspect()
|> Enum.filter(&(rem(&1, 2) == 0))
|> IO.inspect()
|> Enum.reduce(&(&1 + &2))

# ---------------------------------------

# > iex -S mix

Ws2019.User.new()
Ws2019.User.new(age: 44)
Ws2019.User.new(age: 44, tags: [:platinum, :metalhead, :senior_treehugger])
Ws2019.User.new(tags: [:platinum, :metalhead, :senior_treehugger], age: 44)
%Ws2019.User{}

# Process
@doc """
- Send Message / receive message
- Link Monitor
- GenServer / GenStateMachine
"""

self()
spawn(fn -> Process.sleep(1000); IO.puts("DONE #{inspect self()}") end)
pid = spawn(fn -> Process.sleep(1000); IO.puts("DONE #{inspect self()}") end)
parent = self
pid = spawn(fn -> Process.sleep(1000); IO.puts("DONE #{inspect self()}"); send(parent, {:done, self()}) end)
Process.alive? pid

self
spawn(fn -> Process.sleep(1000); IO.puts("try to dived by Zero"); 1/0; IO.puts("ininite") end)
self

flush
self
spawn_monitor(fn -> Process.sleep(1000); IO.puts("try to dived by Zero"); 1/0; IO.puts("ininite") end)
self
flush

self
spawn_link(fn -> Process.sleep(1000); IO.puts("try to dived by Zero"); 1/0; IO.puts("ininite") end)
self

# Debugging
@doc """
- Observer
"""

:observer.start()
# in Logger kill the bottom right and then top
