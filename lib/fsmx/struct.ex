defmodule Fsmx.Struct do
  defmacro __using__(opts \\ []) do
    quote do
      @fsm Keyword.get(unquote(opts), :fsm, __MODULE__)

      if @fsm == __MODULE__ do
        use Fsmx.Fsm, unquote(opts)
      end

      def __fsmx__, do: @fsm
    end
  end
end
