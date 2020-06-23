defmodule Fsmx do
  @type state_t :: binary

  def transition(%mod{state: state} = struct, new_state) do
    transitions = mod.__fsmx__(:transitions)

    if valid_transition?(state, new_state, transitions) do
      {:ok, %{struct | state: new_state}}
    else
      {:error, "invalid transition of #{mod} from #{state} to #{new_state}"}
    end
  end

  defp valid_transition?(state, new_state, transitions) do
    transitions
    |> Map.get(state, [])
    |> is_or_contains?(new_state)
  end

  defp is_or_contains?(state, state), do: true
  defp is_or_contains?(states, state) when is_list(states), do: Enum.member?(states, state)
  defp is_or_contains?(_, _), do: false
end
