defmodule Fiet.Atom.Category do
  defstruct [:term, :scheme, :label]

  def from_element({"category", attributes, _}) do
    %__MODULE__{
      term: get_attribute_value(attributes, "term"),
      scheme: get_attribute_value(attributes, "scheme"),
      label: get_attribute_value(attributes, "label")
    }
  end

  defp get_attribute_value(attributes, name) do
    for({key, value} <- attributes, key == name, do: value)
    |> List.first()
  end
end
