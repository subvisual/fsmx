defmodule Fsmx.Struct do
  @moduledoc """
  Main module to include finite-state machine logic into your struct/schema

  If no `state_field` is defined, it assumes the name is `:state`.

  Basic usage:

  ```elixir
  defmodule MyApp.Struct do
    defstruct [:state]

    use Fsmx.Struct, transitions: %{}
  end
  ```

  You can also specify a custom state field:

  ```elixir
  defmodule MyApp.Struct do
    defstruct [:my_state]

    use Fsmx.Struct, state_field: :my_state, transitions: %{}
  end
  ```

  Or even multiple state fields, that will behave independently and have their
  own transition definition, etc. In this case `:state` is still used as the
  default:

  ```elixir
  defmodule MyApp.Struct do
    defstruct [:state, :other_state]

    use Fsmx.Struct, transitions: %{}
    use Fsmx.Struct, state_field: :other_state, transitions: %{}
  end
  ```
  """

  defmacro __using__(opts \\ []) do
    {state_field, _} = Code.eval_quoted(Keyword.get(opts, :state_field, :state))

    quote do
      fsm = Keyword.get(unquote(opts), :fsm, __MODULE__)

      if fsm == __MODULE__ do
        use Fsmx.Fsm, unquote(opts)
      end

      def __fsmx__(unquote(state_field)), do: Keyword.get(unquote(opts), :fsm, __MODULE__)
    end
  end
end
