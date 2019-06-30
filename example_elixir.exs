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

IO.inspect([1, 2, 3, 4, 5, 6, 7, 8])
IO.inspect([1, 2, 3, 4, 5, 6, 7, 8], label: "lista")
IO.inspect([1, 2, 3, 4, 5, 6, 7, 8], label: "lista", width: 9)

m = %{"s" => 2}
m = %{:a => 2}
m = %{a: 2}
m = %{a: 2, c: 3, d: 4}
m1 = %{:a => 2, :c => 3, :d => 4}
m == m1

l = [1, 2, 3]
[x, y, z] = l
x
y
z
[h | t] = l
h
t
l1 = [h | t]
l1 == l

m = %{a: 2, c: 3, d: 4}
%{a: v} = m
v
2
%{z: v} = m

# Talk about rebinding
m
m = %{x: 9, y: 8, z: 7}
v
%{x: x} = m
x
%{y: x} = m
x
%{z: ^x} = m

# FUNCTIONS
clear
f = fn x, y -> x + y end
f
f.(1, 2)
f.(3, 3)
f.(1)

clear
l = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
l1 = Enum.map(l, fn x -> x * 3 end)
l2 = Enum.filter(l1, fn x -> rem(x, 2) == 0 end)
sum = Enum.reduce(l2, fn x, acc -> x + acc end)
sum

sum = l |> Enum.map(fn x -> x * 3 end) |>
Enum.filter(fn x -> rem(x, 2) == 0 end) |>
Enum.reduce(fn x, acc -> x + acc end)

l = [1, 2, 3, 5, 6, 7, 8, 9, 10]
sum = 1..10 |> Enum.map(&(&1 * 3)) |>
Enum.filter(&(rem(&1, 2) == 0)) |>
Enum.reduce(&(&1 + &2))

# 1..10 |> Enum.map(&(&1 * 3)) |>
# IO.inspect() |>
# Enum.filter(&(rem(&1, 2) == 0)) |>
# IO.inspect() |>
# Enum.reduce(&(&1 + &2))

# ---------------------------------------

# > iex -S mix

Ws2019.User.new()
Ws2019.User.new(age: 44)
Ws2019.User.new(age: 44, tags: [:platinum, :metalhead, :senior_treehugger])
Ws2019.User.new(tags: [:platinum, :metalhead, :senior_treehugger], age: 44)
u = %Ws2019.User{}
is_map(u)

# Process
@doc """
- Send Message / receive message
- Link Monitor
- GenServer / GenStateMachine
"""

self()
Process.list |> length
pid = spawn(fn ->
  Process.sleep(1000)
  IO.puts("DONE #{inspect(self())}")
end)

Process.alive?(pid)

parent = self
pid = spawn(fn ->
  Process.sleep(1000)
  IO.puts("DONE #{inspect(self())}")
  send(parent, {:done, self()})
end)
Process.alive?(pid)
flush

# Process are isolated
clear
self
spawn(fn ->
  Process.sleep(1000)
  IO.puts("try to dived by Zero")
  1 / 0
  IO.puts("Never printed")
end)
self
flush

clear
flush
self
spawn_monitor(fn ->
  Process.sleep(1000)
  IO.puts("try to dived by Zero")
  1 / 0
  IO.puts("NEVER PRINTED!!!")
end)
# wait
self
flush

clear
self
spawn_link(fn ->
  Process.sleep(1000)
  IO.puts("try to dived by Zero")
  1 / 0
  IO.puts("ininite")
end)
# wait
self

# distribution
# > iex --sname server1
# > iex --sname server2

#on server 2
Node.ping(:server1@tardis)
Node.list

#on server 1
Node.list
Agent.start(fn -> 42 end, name: :the_response)

Process.whereis :the_response

Agent.get(:the_response, fn state -> state end)

#on server 2
Process.whereis :the_response
Agent.get({:the_response, :server1@tardis}, fn state -> state end)

# Debugging
@doc """
- Observer
"""

:observer.start()
# in Logger kill the bottom right and then top
