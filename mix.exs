defmodule Ws2019.MixProject do
  use Mix.Project

  def project do
    [
      app: :ws2019,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        flags: [:underspecs, :unknown, :unmatched_returns, :error_handling],
        plt_add_apps: [:mix, :iex, :logger],
        plt_add_deps: :apps_direct,
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_deps: :transitive
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
