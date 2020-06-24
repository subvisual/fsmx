defmodule Fsmx.EctoCase do
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  setup tags do
    :ok = Sandbox.checkout(Fsmx.Repo)

    unless tags[:async] do
      Sandbox.mode(Fsmx.Repo, {:shared, self()})
    end
  end
end
