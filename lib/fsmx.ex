defmodule Fsmx do
  @type state_t :: binary

  def transition(%mod{state: state} = struct, new_state) do
    fsm = mod.__fsmx__()
    transitions = fsm.__fsmx__(:transitions)

    with :ok <- validate_transition(state, new_state, transitions),
         {:ok, struct} <- fsm.before_transition(struct, state, new_state),
         {:ok, struct} <- do_transition(struct, new_state),
         {:ok, struct} <- fsm.after_transition(struct, state, new_state) do
      {:ok, struct}
    end
  end

  defp do_transition(struct, new_state) do
    {:ok, %{struct | state: new_state}}
  end

  defp validate_transition(state, new_state, transitions) do
    transitions
    |> Map.get(state, [])
    |> is_or_contains?(new_state)
    |> if do
      :ok
    else
      {:error, "invalid transition from #{state} to #{new_state}"}
    end
  end

  defp is_or_contains?(state, state), do: true
  defp is_or_contains?(states, state) when is_list(states), do: Enum.member?(states, state)
  defp is_or_contains?(_, _), do: false
end
