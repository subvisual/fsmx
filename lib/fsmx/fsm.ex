defmodule Fsmx.Fsm do
  defmacro __using__(opts \\ []) do
    quote do
      @before_compile unquote(__MODULE__)

      @fsm Keyword.get(unquote(opts), :fsm, __MODULE__)

      def __fsmx__(:transitions), do: Keyword.fetch!(unquote(opts), :transitions)
      def __fsmx__(:fsm), do: @fsm
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: false do
      def before_transition(struct, _from, _to), do: {:ok, struct}
      def transition_changeset(changeset, _from, _to, _params), do: {:ok, changeset}
      def after_transition_multi(struct, _from, _to), do: {:ok, struct}
    end
  end
end
