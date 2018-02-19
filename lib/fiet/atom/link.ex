defmodule Fiet.Atom.Link do
  defstruct [:href, :rel, :type, :href_lang, :title, :length]

  def from_element({"link", attributes, _content}) do
    %__MODULE__{
      href: get_attribute_value(attributes, "href"),
      rel: get_attribute_value(attributes, "rel"),
      type: get_attribute_value(attributes, "type"),
      href_lang: get_attribute_value(attributes, "hreflang"),
      title: get_attribute_value(attributes, "title"),
      length: get_attribute_value(attributes, "length")
    }
  end

  defp get_attribute_value(attributes, name) do
    for({key, value} <- attributes, key == name, do: value)
    |> List.first()
  end
end
