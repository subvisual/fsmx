defmodule Fsmx.TestEctoSchemas.EctoEnumSimple do
  use Ecto.Schema

  schema "test" do
    field :state, Ecto.Enum, values: [:"1", :"2", :"3"]
  end

  use Fsmx.Struct,
    transitions: %{
      :"1" => :"2",
      :"2" => :"3"
    }
end
