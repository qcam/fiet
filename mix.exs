defmodule Fiet.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :fiet,
      version: @version,
      elixir: "~> 1.4",
      package: package(),
      description: description(),
      name: "Fiet",
      deps: deps(),
      docs: [
        main: "Fiet",
        source_ref: "v#{@version}",
        source_url: "https://github.com/qcam/fiet"
      ]
    ]
  end

  def application, do: []

  defp description() do
    "Fiết is a feeds parser in Elixir, which aims to provide extensibility, speed," <>
      " and standard compliance to feed parsing."
  end

  defp package() do
    [
      maintainers: ["Cẩm Huỳnh"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/qcam/fiet"}
    ]
  end

  defp deps() do
    [
      {:saxy, "~> 0.5.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
