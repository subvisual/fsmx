defmodule Fsmx do
  @moduledoc """
  """

  alias Fsmx.Fsm

  @type state_t :: binary() | atom()
  @type opts_t :: [state_field: atom()]

  @spec transition(struct(), state_t(), opts_t()) :: {:ok, struct} | {:error, any}
  def transition(%{} = struct, new_state, opts \\ []) do
    opts = Keyword.put_new(opts, :state_field, Fsm.default_state_field())
    state_field = Keyword.get(opts, :state_field)

    with {:ok, struct} <- before_transition(struct, new_state, state_field) do
      {:ok, struct |> Map.put(state_field, new_state)}
    end
  end

  if Code.ensure_loaded?(Ecto) do
    @spec transition_changeset(struct(), state_t(), map, opts_t()) :: Ecto.Changeset.t()
    def transition_changeset(%mod{} = schema, new_state, params \\ %{}, opts \\ []) do
      opts = Keyword.put_new(opts, :state_field, Fsm.default_state_field())
      state_field = Keyword.get(opts, :state_field)
      state = schema |> Map.fetch!(state_field)
      fsm = mod.__fsmx__(state_field)

      with {:ok, schema} <- before_transition(schema, new_state, state_field) do
        schema
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(state_field, new_state)
        |> then(fn changeset ->
          if function_exported?(fsm, :transition_changeset, 4) do
            fsm.transition_changeset(changeset, state, new_state, params)
          else
            fsm.transition_changeset(changeset, state, new_state, params, state_field)
          end
        end)
      else
        {:error, msg} ->
          schema
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.add_error(state_field, "transition_changeset failed: #{msg}")
      end
    end

    @spec transition_multi(Ecto.Multi.t(), struct(), any, state_t, map, opts_t()) ::
            Ecto.Multi.t()
    def transition_multi(multi, %mod{} = schema, id, new_state, params \\ %{}, opts \\ []) do
      opts = Keyword.put_new(opts, :state_field, Fsm.default_state_field())
      state_field = Keyword.get(opts, :state_field)
      state = schema |> Map.fetch!(state_field)
      fsm = mod.__fsmx__(state_field)

      changeset = transition_changeset(schema, new_state, params, state_field: state_field)

      multi
      |> Ecto.Multi.update(id, changeset)
      |> Ecto.Multi.run("#{id}-callback", fn _repo, changes ->
        if function_exported?(fsm, :after_transition_multi, 3) do
          fsm.after_transition_multi(Map.fetch!(changes, id), state, new_state)
        else
          fsm.after_transition_multi(Map.fetch!(changes, id), state, new_state, state_field)
        end
      end)
    end
  end

  defp before_transition(%mod{} = struct, new_state, state_field) do
    fsm = mod.__fsmx__(state_field)
    state = struct |> Map.fetch!(state_field)
    transitions = fsm.__fsmx__(state_field, :transitions)

    with :ok <- validate_transition(state, new_state, transitions, state_field) do
      if function_exported?(fsm, :before_transition, 3) do
        fsm.before_transition(struct, state, new_state)
      else
        fsm.before_transition(struct, state, new_state, state_field)
      end
    end
  end

  defp validate_transition(state, new_state, transitions, state_field) do
    transitions
    |> from_source_or_fallback(state)
    |> is_or_contains?(new_state)
    |> if do
      :ok
    else
      if state_field == Fsm.default_state_field() do
        {:error, "invalid transition from #{state} to #{new_state}"}
      else
        {:error, "invalid transition from #{state} to #{new_state} for field #{state_field}"}
      end
    end
  end

  defp from_source_or_fallback(transition, state) do
    Map.take(transition, [state, :*])
    |> Enum.flat_map(fn
      {_, valid_states} when is_list(valid_states) -> valid_states
      {_, valid_state} -> [valid_state]
    end)
  end

  defp is_or_contains?(:*, _), do: true
  defp is_or_contains?(state, state), do: true

  defp is_or_contains?(states, state) when is_list(states),
    do: Enum.member?(states, state) || Enum.member?(states, :*)

  defp is_or_contains?(_, _), do: false
end
