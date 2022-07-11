defmodule Fsmx do
  @moduledoc """
  """

  @type state_t :: binary() | atom()

  @spec transition(struct(), state_t()) :: {:ok, struct} | {:error, any}
  def transition(%mod{} = struct, new_state) do
    fsm = mod.__fsmx__()
    with {:ok, struct} <- before_transition(struct, new_state) do
      state_field = fsm.__fsmx__(:state_field)
      {:ok, struct |> Map.put(state_field,  new_state)}
    end
  end

  if Code.ensure_loaded?(Ecto) do
    @spec transition_changeset(struct(), state_t(), map) :: Ecto.Changeset.t()
    def transition_changeset(%mod{} = schema, new_state, params \\ %{}) do
      fsm = mod.__fsmx__()
      state_field = fsm.__fsmx__(:state_field)
      state = schema |> Map.fetch!(state_field)

      with {:ok, schema} <- before_transition(schema, new_state) do
        schema
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(state_field, new_state)
        |> fsm.transition_changeset(state, new_state, params)
      else
        {:error, msg} ->
          schema
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.add_error(state_field, "transition_changeset failed: #{msg}")
      end
    end

    @spec transition_multi(Ecto.Multi.t(), struct(), any, state_t, map) :: Ecto.Multi.t()
    def transition_multi(multi, %mod{} = schema, id, new_state, params \\ %{}) do
      fsm = mod.__fsmx__()
      state = schema |> Map.fetch!(fsm.__fsmx__(:state_field))

      changeset = transition_changeset(schema, new_state, params)

      multi
      |> Ecto.Multi.update(id, changeset)
      |> Ecto.Multi.run("#{id}-callback", fn _repo, changes ->
        fsm.after_transition_multi(Map.fetch!(changes, id), state, new_state)
      end)
    end
  end

  defp before_transition(%mod{} = struct, new_state) do
    fsm = mod.__fsmx__()
    state = struct |> Map.fetch!(fsm.__fsmx__(:state_field))
    transitions = fsm.__fsmx__(:transitions)

    with :ok <- validate_transition(state, new_state, transitions) do
      fsm.before_transition(struct, state, new_state)
    end
  end

  defp validate_transition(state, new_state, transitions) do
    transitions
    |> from_struct_and_any(state)
    |> is_or_contains?(new_state)
    |> if do
      :ok
    else
      {:error, "invalid transition from #{state} to #{new_state}"}
    end
  end

  defp from_struct_and_any(transition, state) do
    Map.take(transition, [state, :*])
    |> Enum.flat_map(&elem(&1, 1))
  end

  defp is_or_contains?(:*, _), do: true
  defp is_or_contains?(state, state), do: true
  defp is_or_contains?(states, state) when is_list(states), do: Enum.member?(states, state)
  defp is_or_contains?(_, _), do: false
end
