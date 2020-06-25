defmodule Fsmx do
  @moduledoc """
  """

  @spec transition(struct(), binary()) :: {:ok, struct} | {:error, any}
  def transition(struct, new_state) do
    with {:ok, struct} <- before_transition(struct, new_state) do
      {:ok, %{struct | state: new_state}}
    end
  end

  if Code.ensure_loaded?(Ecto) do
    @spec transition_changeset(struct(), binary, map) :: Ecto.Changeset.t()
    def(transition_changeset(%mod{state: state} = schema, new_state, params \\ %{})) do
      fsm = mod.__fsmx__()

      with {:ok, schema} <- before_transition(schema, new_state) do
        schema
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:state, new_state)
        |> fsm.transition_changeset(state, new_state, params)
      else
        {:error, msg} ->
          schema
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.add_error(:state, "transition_changeset failed: #{msg}")
      end
    end

    @spec transition_multi(Ecto.Multi.t(), struct(), any, binary, map) :: Ecto.Multi.t()
    def transition_multi(multi, %mod{state: state} = schema, id, new_state, params \\ %{}) do
      fsm = mod.__fsmx__()

      changeset = transition_changeset(schema, new_state, params)

      multi
      |> Ecto.Multi.update(id, changeset)
      |> Ecto.Multi.run("#{id}-callback", fn _repo, changes ->
        fsm.after_transition_multi(Map.fetch!(changes, id), state, new_state)
      end)
    end
  end

  defp before_transition(%mod{state: state} = struct, new_state) do
    fsm = mod.__fsmx__()
    transitions = fsm.__fsmx__(:transitions)

    with :ok <- validate_transition(state, new_state, transitions) do
      fsm.before_transition(struct, state, new_state)
    end
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
