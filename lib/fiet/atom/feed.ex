defmodule Fiet.Atom.Feed do
  @type t :: %__MODULE__{
          id: binary | nil,
          title: {:text | :html, title :: binary} | nil,
          updated: binary | nil,
          links: list(Fiet.Atom.Link.t()),
          generator: Fiet.Atom.Generator.t() | nil,
          subtitle: {:text | :html, title :: binary} | nil,
          rights: {:text | :html, title :: binary} | nil,
          logo: binary | nil,
          icon: binary | nil,
          authors: list(Fiet.Atom.Person.t()),
          contributors: list(Fiet.Atom.Person.t()),
          categories: list(Fiet.Atom.Category.t()),
          entries: list(Fiet.Atom.Entry.t())
        }

  defstruct [
    :id,
    :title,
    :updated,
    :rights,
    :subtitle,
    :logo,
    :icon,
    :generator,
    links: [],
    authors: [],
    categories: [],
    contributors: [],
    entries: []
  ]
end
