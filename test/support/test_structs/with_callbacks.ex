defmodule Fsmx.TestStructs.WithCallbacks do
  defmodule ValidBefore do
    defstruct state: "1", before: false

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def before_transition(struct, "1", _new_state) do
      {:ok, %{struct | before: "1"}}
    end
  end

  defmodule InvalidBefore do
    defstruct state: "1", before: false

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def before_transition(_struct, "1", _new_state) do
      {:error, :before_failed}
    end
  end

  defmodule PartialCallback do
    defstruct state: "1", before: false

    use Fsmx.Struct, transitions: %{"1" => "2", "2" => "3"}

    def before_transition(struct, "1", "2") do
      {:ok, struct}
    end
  end
end
