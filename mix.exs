defmodule UeberauthHubspot.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/bchase/ueberauth_hubspot"

  def project do
    [
      app: :ueberauth_hubspot,
      version: @version,
      elixir: "~> 1.3",
      name: "Ueberauth HubSpot",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @url,
      homepage_url: @url,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth] ++ env_apps(Mix.env())]
  end

  defp env_apps(:dev), do: [:makeup, :makeup_elixir, :makeup_erlang, :ex_doc]
  defp env_apps(_), do: []

  defp deps do
    [
      {:ueberauth, "~> 0.7"},
      {:oauth2, "~> 1.0 or ~> 2.0"},

      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:earmark, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Uberauth strategy for HubSpot authentication."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Brad Chase"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end
