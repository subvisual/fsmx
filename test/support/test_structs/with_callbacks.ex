defmodule Fsmx.TestStructs.WithCallbacks do
  defmodule ValidBefore do
    defstruct state: "1", before: false, after: false

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def before_transition(struct, _old_state, _new_state) do
      {:ok, %{struct | before: true}}
    end
  end

  defmodule ValidAfter do
    defstruct state: "1", before: false, after: false

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def after_transition(struct, _old_state, _new_state) do
      {:ok, %{struct | after: true}}
    end
  end

  defmodule InvalidBefore do
    defstruct state: "1", before: false, after: false

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def before_transition(struct, _old_state, _new_state) do
      {:error, :before_failed}
    end
  end

  defmodule InvalidAfter do
    defstruct state: "1", before: false, after: false

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def after_transition(struct, _old_state, _new_state) do
      {:error, :after_failed}
    end
  end

  defmodule PartialCallback do
    defstruct state: "1", before: false, after: false

    use Fsmx.Struct, transitions: %{"1" => "2", "2" => "3"}

    def after_transition(struct, "1", "2") do
      {:ok, struct}
    end
  end
end
