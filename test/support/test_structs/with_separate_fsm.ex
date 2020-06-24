defmodule Fsmx.TestStructs.WithSeparateFsm do
  defstruct [:state, before: false, after: false]

  use Fsmx.Struct, fsm: __MODULE__.Fsm

  defmodule Fsm do
    use Fsmx.Fsm, transitions: %{"1" => "2"}

    def before_transition(struct, _, _), do: {:ok, %{struct | before: true}}

    def after_transition(struct, _, _), do: {:ok, %{struct | after: true}}
  end
end
