import Config

config :fsmx, ecto_repos: [Fsmx.Repo]

config :fsmx, Fsmx.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASS") || "postgres",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  database: "fsmx_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
