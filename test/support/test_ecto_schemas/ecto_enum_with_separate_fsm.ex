defmodule Fsmx.TestEctoSchemas.EctoEnumWithSeparateFsm do
  use Ecto.Schema

  schema "test" do
    field :state, Ecto.Enum, values: [:"1", :"2"]
    field :before, :string
  end

  use Fsmx.Struct, fsm: __MODULE__.Fsm

  defmodule Fsm do
    use Fsmx.Fsm, transitions: %{:"1" => :"2"}

    def before_transition(schema, :"1", _), do: {:ok, %{schema | before: :"1"}}
  end
end
