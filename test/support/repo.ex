defmodule Fsmx.Repo do
  use Ecto.Repo,
    otp_app: :postgrex,
    adapter: Ecto.Adapters.Postgres,
    priv: "test/support/repo/migrations"
end
