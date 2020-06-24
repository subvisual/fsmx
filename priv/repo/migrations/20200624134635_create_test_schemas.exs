defmodule Fsmx.Repo.Migrations.CreateTestSchemas do
  use Ecto.Migration

  def change do
    create table(:test) do
      add :state, :string
      add :before, :string
    end
  end
end
