defmodule Fsmx.TestStructs.WithCallbacks do
  defstruct [:state]

  use Fsmx.Struct, transitions: %{"1" => ["2"], "2" => ["3"]}

  def before_transition(struct, state) do
    IO.inspect(struct, state)
  end
end
