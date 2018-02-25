defmodule Fiet.Atom.Entry do
  @type t :: %__MODULE__{
          id: binary | nil,
          title: {:text | :html, title :: binary} | nil,
          summary: {:text | :html, title :: binary} | nil,
          content: {:text | :html, title :: binary} | nil,
          published: binary | nil,
          link: Fiet.Atom.Link.t() | nil,
          rights: {:text | :html, title :: binary} | nil,
          authors: list(Fiet.Atom.Person.t()),
          contributors: list(Fiet.Atom.Person.t()),
          categories: list(Fiet.Atom.Category.t())
        }

  defstruct [
    :id,
    :title,
    :updated,
    :summary,
    :content,
    :published,
    :link,
    :rights,
    authors: [],
    categories: [],
    contributors: []
  ]
end
