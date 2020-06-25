defmodule Fsmx.Struct do
  @moduledoc """
  Main module to include finite-state machine logic into your struct/schema

  It assumes a `:state` string field exists in your model

  Basic usage:

  ```elixir
  defmodule MyApp.Struct do
    defstruct [:state]

    use Fsmx.Struct, transitions: %{}
  end
  ```
  """

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
