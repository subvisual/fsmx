{:ok, _} = Fsmx.Repo.start_link()

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Fsmx.Repo, :manual)
