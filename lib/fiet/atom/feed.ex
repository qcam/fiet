defmodule Fiet.Atom.Feed do
  defstruct [
    :id,
    :title,
    :updated,
    :link,
    :rights,
    :subtitle,
    :logo,
    :icon,
    :generator,
    authors: [],
    categories: [],
    contributors: [],
    entries: []
  ]
end
