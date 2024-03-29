defmodule Haystack.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/elixir-haystack/haystack"

  def project do
    [
      app: :haystack,
      name: "Haystack",
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      source_url: "https://github.com/elixir-haystack/haystack",
      homepage_url: "https://github.com/elixir-haystack/haystack",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15", only: :test},
      {:stemmer, "~> 1.1"},
      {:jason, "~> 1.4"}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp description() do
    "Simple, extendable full-text search engine written in Elixir"
  end

  defp docs do
    [
      main: "Haystack",
      source_ref: "v#{@version}",
      source_url: @url
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Philip Brown"],
      links: %{"GitHub" => @url}
    ]
  end
end
