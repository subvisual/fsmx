defmodule Fsmx.MixProject do
  use Mix.Project

  @version "0.5.0"

  def project do
    [
      app: :fsmx,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      applications: applications(Mix.env()),
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
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
      {:ecto_sql, ">= 3.0.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "A Finite-state machine implementation in Elixir, with opt-in Ecto friendliness."
  end

  defp package do
    [
      maintainers: ["Miguel Palhas"],
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/subvisual/fsmx"},
      files: ~w(.formatter.exs mix.exs README.md lib LICENSE)
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/subvisual/fsmx",
      source_ref: "v#{@version}"
    ]
  end
end
