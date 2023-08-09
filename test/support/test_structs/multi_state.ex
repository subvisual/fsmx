defmodule Fsmx.TestStructs.MultiState do
  defstruct [:state, :other_state]

  use Fsmx.Struct,
    transitions: %{"1" => ["2"], "2" => ["3"], "3" => :*}

  use Fsmx.Struct,
    state_field: :other_state,
    transitions: %{"1" => ["2"], "2" => ["3"], "3" => :*}
end
