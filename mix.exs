defmodule Fsmx.MixProject do
  use Mix.Project

  def project do
    [
      app: :fsmx,
      version: "0.1.0",
      elixir: "~> 1.8",
      applications: applications(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.

  def application do
    [extra_applications: applications(Mix.env())]
  end

  defp applications(:test), do: [:logger, :ecto]
  defp applications(_), do: [:logger]

  defp deps do
    [
      {:postgrex, ">= 0.0.0", only: :test},
      {:ecto, ">= 3.0.0", optional: true},
      {:ecto_sql, ">= 3.0.0", optional: true}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
