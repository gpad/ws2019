defmodule Ws2019.Policies.Switch do
  use GenStateMachine, callback_mode: :state_functions

  @moduledoc """
  iex(3)> send(pid, {:ciao, 43})
  I'm OFF and I have received a generic event!!!!
  {:ciao, 43}
  Keep state and data and do nothing:
          event_type: :info
          event_content: {:ciao, 43}
          data: 3


  """

  def start_link(value) do
    GenStateMachine.start_link(__MODULE__, [value])
  end

  def init([value]) do
    {:ok, :off, value}
  end

  def off(:cast, :flip, data) do
    IO.puts("I'm OFF turn the light ON!!!")
    # Turn off automatically after 5 minutes ...
    {:next_state, :on, data + 1, {:state_timeout, 5000, :auto_turn_off}}
  end

  def off(event_type, event_content, data) do
    IO.puts("I'm OFF and I have received a generic event!!!!")
    handle_event(event_type, event_content, data)
  end

  def on(:cast, :flip, data) do
    IO.puts("I'm ON and I turn OFF!!!")
    {:next_state, :off, data}
  end

  def on(:state_timeout, :auto_turn_off, data) do
    IO.puts("I'm ON and I turn OFF automatically ...")
    {:next_state, :off, data}
  end

  def on(event_type, event_content, data) do
    IO.puts("I'm ON and I have received a generic event!!!!")
    handle_event(event_type, event_content, data)
  end

  def handle_info(msg, data) do
    IO.puts("Received a generic message: #{inspect(msg)} - date: #{inspect(data)}")
    {:noreplay, data}
  end

  def handle_event({:call, from}, :get_count, data) do
    IO.puts("Keep state and data but reply to caller (get_count)!!!")
    {:keep_state_and_data, [{:reply, from, data}]}
  end

  def handle_event({:call, from}, event_content, data) do
    IO.puts(
      "Keep state and data and do nothing:\n\tevent_type: #{inspect({:call, from})}\n\tevent_content: #{
        inspect(event_content)
      }\n\tdata: #{inspect(data)}\n"
    )

    {:keep_state_and_data, [{:reply, from, data}]}
  end

  def handle_event(event_type, event_content, data) do
    IO.puts(
      "Keep state and data and do nothing:\n\tevent_type: #{inspect(event_type)}\n\tevent_content: #{
        inspect(event_content)
      }\n\tdata: #{inspect(data)}\n"
    )

    :keep_state_and_data
  end
end
