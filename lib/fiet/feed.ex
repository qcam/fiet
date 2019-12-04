defmodule Fiet.Feed do
  @moduledoc """
  A unified format for all the feeds supported by Fiet.
  """

  @type t :: %__MODULE__{
          title: binary | nil,
          link: binary | nil,
          description: binary | nil,
          updated_at: binary | nil,
          categories: list(binary),
          items: list(Fiet.Item.t())
        }

  defstruct [
    :title,
    :link,
    :description,
    :updated_at,
    categories: [],
    items: []
  ]

  alias Fiet.{Atom, RSS2, Item}

  @doc false

  def new(%Atom.Feed{} = feed) do
    %{
      title: title,
      links: links,
      subtitle: subtitle,
      updated: updated,
      categories: categories,
      entries: entries
    } = feed

    %__MODULE__{
      title: text_construct(title),
      link: extract_atom_link(links),
      description: text_construct(subtitle),
      updated_at: updated,
      categories: map_categories(categories),
      items: map_items(entries)
    }
  end

  def new(%RSS2.Channel{} = feed) do
    %{
      title: title,
      link: link,
      description: description,
      last_build_date: last_build_date,
      categories: categories,
      items: items
    } = feed

    %__MODULE__{
      title: title,
      link: link,
      description: description,
      updated_at: last_build_date,
      categories: map_categories(categories),
      items: map_items(items)
    }
  end

  defp map_categories(categories, acc \\ [])

  defp map_categories([], acc), do: Enum.reverse(acc)

  defp map_categories([%Atom.Category{} = category | categories], acc) do
    %{term: term} = category
    map_categories(categories, [term | acc])
  end

  defp map_categories([%RSS2.Category{} = category | categories], acc) do
    %{value: value} = category
    map_categories(categories, [value | acc])
  end

  defp map_items(items, acc \\ [])

  defp map_items([], acc), do: Enum.reverse(acc)

  defp map_items([%Atom.Entry{} = entry | items], acc) do
    %{
      id: id,
      title: title,
      links: links,
      summary: summary,
      published: published,
      updated: updated
    } = entry

    item = %Item{
      id: id,
      title: text_construct(title),
      description: text_construct(summary),
      link: extract_atom_link(links),
      published_at: published || updated
    }

    map_items(items, [item | acc])
  end

  defp map_items([%RSS2.Item{} = item | items], acc) do
    %{
      guid: guid,
      title: title,
      link: link,
      description: description,
      pub_date: pub_date
    } = item

    item = %Item{
      id: guid,
      title: title,
      description: description,
      link: link,
      published_at: pub_date
    }

    map_items(items, [item | acc])
  end

  defp text_construct({_type, content}), do: content
  defp text_construct(nil), do: nil

  defp extract_atom_link(links = [link | _links]) when is_list(links) do
    cond do
      href = Enum.find_value(links, &extract_atom_link/1) -> href
      true -> link.href
    end
  end

  defp extract_atom_link(%Atom.Link{href: href, rel: "self"}), do: href
  defp extract_atom_link(_link), do: nil
end
