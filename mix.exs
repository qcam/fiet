defmodule Fiet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fiet,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: []

  defp deps do
    [
      {:saxy, "0.2.0-rc1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
