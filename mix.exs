defmodule Viet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :viet,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: []

  defp deps do
    [{:saxy, "0.2.0-rc1"}]
  end
end
