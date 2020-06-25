defmodule Fsmx.Repo do
  use Ecto.Repo,
    otp_app: :fsmx,
    adapter: Ecto.Adapters.Postgres,
    show_sensitive_data_on_connection_error: true
end
