defmodule Fsmx.TestEctoSchemas.MultiState do
  use Ecto.Schema

  schema "test" do
    field :state, :string
    field :other_state, :string
  end

  use Fsmx.Struct, transitions: %{"1" => "2"}

  use Fsmx.Struct, state_field: :other_state, transitions: %{"1" => "2"}
end
