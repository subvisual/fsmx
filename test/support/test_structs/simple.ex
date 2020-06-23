defmodule Fsmx.TestStructs.Simple do
  defstruct [:state]

  use Fsmx.Struct, transitions: %{"1" => ["2"], "2" => ["3"]}
end
