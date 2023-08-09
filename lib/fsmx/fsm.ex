defmodule Fsmx.Fsm do
  @moduledoc """
  Holds transition and callback logic for finite state machines

  By default, when using `use Fsmx.Struct`, this is automatically included as well.
  Specifying `use Fsmx.Struct, fsm: MyApp.Fsm` allows you to decouple this, though

  ```elixir
  defmodule MyApp.Struct do
    defstruct [:state]
  end

  defmodule MyApp.Fsm do
    use Fsmx.Fsm, transitions: %{}

    def before_transition(struct, _from, _to, _state_field) do
      # ...
    end
  end
  ```

  ## Callbacks

  Callbacks are defined as functions in the module that includes `Fsmx.Fsm`
  (which could be the one that includes `Fsmx.Struct`). They are called with
  the struct, the current state, the new state, and the state field name. This
  allows for different callbacks per state field.

  The following callbacks are deprecated and will be removed in a future:
  - `before_transition/3`
  - `transition_changeset/4`
  - `after_transition_multi/3`
  """

  @callback before_transition(struct, Fsmx.state_t(), Fsmx.state_t(), atom()) ::
              {:ok, struct} | {:error, any}

  if Code.ensure_loaded?(Ecto) do
    @callback transition_changeset(Ecto.Schema.t(), Fsmx.state_t(), Fsmx.state_t(), map(), atom()) ::
                Ecto.Changeset.t()
    @callback after_transition_multi(struct, Fsmx.state_t(), Fsmx.state_t(), atom()) ::
                {:ok, struct} | {:error, any}
  end

  def default_state_field do
    :state
  end

  defmacro __using__(opts \\ []) do
    {state_field, _} = Code.eval_quoted(Keyword.get(opts, :state_field, :state))

    quote do
      @before_compile unquote(__MODULE__)

      def __fsmx__(unquote(state_field), :transitions),
        do: Keyword.fetch!(unquote(opts), :transitions)

      def __fsmx__(unquote(state_field), :fsm), do: Keyword.get(unquote(opts), :fsm, __MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: false do
      def before_transition(struct, _from, _to, _state_field), do: {:ok, struct}

      if Code.ensure_loaded?(Ecto) do
        def transition_changeset(changeset, _from, _to, _params, _state_field), do: changeset
        def after_transition_multi(struct, _from, _to, _state_field), do: {:ok, struct}
      end
    end
  end
end
