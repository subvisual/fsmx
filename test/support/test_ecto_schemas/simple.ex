defmodule Fsmx.TestEctoSchemas.Simple do
  use Ecto.Schema

  schema "test" do
    field :state, :string
  end

  use Fsmx.Struct, transitions: %{"1" => "2"}
end
