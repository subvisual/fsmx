defmodule Fsmx.TestEctoSchemas.WithChangesets do
  use Ecto.Schema

  import Ecto.Changeset

  schema "test" do
    field(:state, :string, default: "one")
    field(:data, :map)
  end

  use Fsmx.Struct,
    transitions: %{
      "one" => ["two", "three"]
    }

  def transition_changeset(changeset, "one", "two", params) do
    changeset
    |> cast(params, [:data])
    |> validate_required([:data])
  end
end
