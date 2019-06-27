defmodule Ws2019.Policies.AntiFraud do
  use GenStateMachine, callback_mode: :state_functions
  require Logger

  @doc """
  Too many payments failed block the account!!!
  """

  def start_link(aggregate_id) do
    GenStateMachine.start_link(__MODULE__, [aggregate_id], name: :"anti_fraud_#{aggregate_id}")
  end

  def init([aggregate_id]) do
    :ok = register("money")
    {:ok, :regular, %{entered_at: nil, aggregate_id: aggregate_id}}
  end

  def regular(:cast, {:payment_refused, event}, %{entered_at: entered_at} = data) do
    entered_at = entered_at || event.header.emitted_at

    case DateTime.compare(event.header.emitted_at, entered_at) do
      :lt ->
        :keep_state_and_data

      _ ->
        Logger.info(
          "Account #{data.aggregate_id} goes in warning state, because:\n\t#{inspect(event)}"
        )

        {:next_state, :warning, %{data | entered_at: event.header.emitted_at},
         {:state_timeout, 5000, event}}
    end
  end

  def regular(:cast, {:payment_accepted, event}, %{entered_at: entered_at} = data) do
    entered_at = entered_at || event.header.emitted_at

    case DateTime.compare(event.header.emitted_at, entered_at) do
      :lt -> :keep_state_and_data
      _ -> {:keep_state, %{data | entered_at: event.header.emitted_at}}
    end
  end

  def regular(event_type, event_content, data), do: handle_event(event_type, event_content, data)

  def warning(:cast, {:payment_accepted, event}, %{entered_at: entered_at} = data) do
    entered_at = entered_at || event.header.emitted_at

    case DateTime.compare(event.header.emitted_at, entered_at) do
      :lt ->
        :keep_state_and_data

      _ ->
        {:next_state, :regular, %{data | entered_at: event.header.emitted_at}}
    end
  end

  def warning(:cast, {:payment_refused, event}, %{entered_at: entered_at} = data) do
    case DateTime.compare(event.header.emitted_at, entered_at) do
      :lt -> :keep_state_and_data
      _ -> {:keep_state, %{data | entered_at: event.header.emitted_at}}
    end
  end

  def warning(:state_timeout, event, %{aggregate_id: aggregate_id} = data) do
    Logger.info("Block account #{aggregate_id} - because:\n\t#{inspect(event)}")
    Ws2019.Aggregates.Account.block(aggregate_id, "Timeout Payment Refused")
    {:next_state, :blocked, data}
  end

  def warning(_, _, _), do: :keep_state_and_data

  def blocked(_, _, _), do: :keep_state_and_data

  defp register(topic) do
    {:ok, _} = Registry.register(:event_dispatcher, topic, [])
    :ok
  end

  defp handle_event(:info, {:broad_cast_event, event}, data) do
    {:ok, new_data} = handle_domain_event(event, data)
    {:keep_state, new_data}
  end

  defp handle_event(_event_type, _event_content, _data), do: :keep_state_and_data

  # def handle_info({:broad_cast_event, event}, state) do
  #   {:ok, new_state} = handle_domain_event(event, state)
  #   {:noreply, new_state}
  # end

  defp handle_domain_event(
         %{event_id: :payment_refused, aggregate_id: aggregate_id} = event,
         %{aggregate_id: aggregate_id} = state
       ) do
    GenStateMachine.cast(self(), {:payment_refused, event})
    {:ok, state}
  end

  defp handle_domain_event(
         %{event_id: :payment_accepted, aggregate_id: aggregate_id} = event,
         %{aggregate_id: aggregate_id} = state
       ) do
    GenStateMachine.cast(self(), {:payment_accepted, event})
    {:ok, state}
  end

  defp handle_domain_event(_event, state), do: {:ok, state}
end
