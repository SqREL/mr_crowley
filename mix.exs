defmodule Crawler.Mixfile do
  use Mix.Project

  def project do
    [app: :crawler,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {Crawler, []},
      applications: [:logger, :httpotion, :exredis]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ibrowse, "~> 4.2.2"},
      {:httpotion, "~> 3.0.2"},
      {:floki, "~> 0.11.0"},
      {:json, "~> 1.0.0"},
      {:poolboy, "~> 1.5"},
      {:exredis, ">= 0.2.4"}
    ]
  end
end
