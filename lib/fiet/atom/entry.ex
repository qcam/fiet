defmodule Fiet.Atom.Entry do
  defstruct [
    :id,
    :title,
    :updated,
    :summary,
    :content,
    :published,
    :link,
    :source,
    :rights,
    authors: [],
    categories: [],
    contributors: []
  ]
end
