defmodule Fsmx.Struct do
  defmacro __using__(opts) do
    quote do
      def __fsmx__(:transitions), do: Keyword.fetch!(unquote(opts), :transitions)
    end
  end
end
