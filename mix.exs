defmodule Issues.Mixfile do
  use Mix.Project

  def project do
    [
     app: :issues,
     escript: escript_config(),
     version: "0.0.1",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()
    ]
  end

  def application do
    [
      applications: [:httpoison],
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1.0"}
    ]
  end

  defp escript_config do
    [ main_module: Github.CLI]
  end
end
