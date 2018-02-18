defmodule Fiet.Atom.Generator do
  defstruct [:uri, :version, :text]

  def from_element({"generator", attributes, content}) do
    %__MODULE__{
      uri: get_attribute_value(attributes, "uri"),
      version: get_attribute_value(attributes, "version"),
      text: content
    }
  end

  defp get_attribute_value(attributes, name) do
    for({key, value} <- attributes, key == name, do: value)
    |> List.first()
  end
end
