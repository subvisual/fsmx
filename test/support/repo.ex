defmodule Fsmx.Repo do
  use Ecto.Repo,
    otp_app: :postgrex,
    adapter: Ecto.Adapters.Postgres
end
