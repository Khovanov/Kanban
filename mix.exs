defmodule Kanban.MixProject do
  use Mix.Project

  def project do
    [
      app: :kanban,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kanban.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Time
      {:timex, "~> 3.0"},
      # DB
      {:ecto, "~> 3.0"},
      # Static code analysis
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      # Security
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false}
    ]
  end
end
