defmodule Fsmx.TestStructs.WithFallback do
  defstruct [:state]

  use Fsmx.Struct, transitions: %{"1" => ["2"], "2" => ["3"], :* => ["1"]}
end
