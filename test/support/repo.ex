defmodule Fsmx.Repo do
  use Ecto.Repo,
    otp_app: :fsmx,
    adapter: Ecto.Adapters.Postgres,
    priv: "test/support/repo/migrations"
end
