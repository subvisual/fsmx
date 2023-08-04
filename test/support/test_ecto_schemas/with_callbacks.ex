defmodule Fsmx.TestEctoSchemas.WithCallbacks do
  defmodule ValidBefore do
    use Ecto.Schema

    schema "test" do
      field :state, :string
      field :before, :string
    end

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def before_transition(struct, "1", _new_state) do
      {:ok, %{struct | before: "1"}}
    end
  end

  defmodule InvalidBefore do
    use Ecto.Schema

    schema "test" do
      field :state, :string
      field :before, :string
    end

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def before_transition(_struct, "1", _new_state) do
      {:error, :before_failed}
    end
  end

  defmodule ValidAfterMulti do
    use Ecto.Schema

    schema "test" do
      field :state, :string
    end

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def after_transition_multi(_struct, "1", _new_state) do
      send(self(), :after_transition_multi_called)
      {:ok, nil}
    end
  end

  defmodule InvalidAfterMulti do
    use Ecto.Schema

    schema "test" do
      field :state, :string
    end

    use Fsmx.Struct, transitions: %{"1" => "2"}

    def after_transition_multi(_struct, "1", _new_state) do
      {:error, :after_transition_multi_failed}
    end
  end

  defmodule MultiStateValidBefore do
    use Ecto.Schema

    schema "test" do
      field :state, :string
      field :other_state, :string
      field :before, :string
    end

    use Fsmx.Struct, transitions: %{"1" => "2"}
    use Fsmx.Struct, state_field: :other_state, transitions: %{"1" => "2"}

    def before_transition(struct, "1", _new_state, :state) do
      {:ok, %{struct | before: "1"}}
    end

    def before_transition(struct, "1", _new_state, :other_state) do
      {:ok, %{struct | before: "2"}}
    end
  end
end
