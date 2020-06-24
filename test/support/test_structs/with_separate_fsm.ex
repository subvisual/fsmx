defmodule Fsmx.TestStructs.WithSeparateFsm do
  defstruct [:state, before: false]

  use Fsmx.Struct, fsm: __MODULE__.Fsm

  defmodule Fsm do
    use Fsmx.Fsm, transitions: %{"1" => "2"}

    def before_transition(struct, "1", _), do: {:ok, %{struct | before: "1"}}
  end
end
