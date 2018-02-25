defmodule Fiet.RSS2.Item do
  defmodule Enclosure do
    @type t :: %__MODULE__{
            url: binary | nil,
            length: binary | nil,
            type: binary | nil
          }

    defstruct [:url, :length, :type]
  end

  @moduledoc """
  A struct that represents <item> in RSS 2.0.
  """

  @type t :: %__MODULE__{
          title: binary | nil,
          link: binary | nil,
          description: binary | nil,
          author: binary | nil,
          categories: list(Fiet.RSS2.Category.t()),
          comments: binary | nil,
          enclosure: Enclosure.t() | nil,
          guid: binary | nil,
          pub_date: binary | nil,
          source: binary | nil,
          extras: map
        }

  defstruct [
    :title,
    :link,
    :description,
    :author,
    :categories,
    :comments,
    :enclosure,
    :guid,
    :pub_date,
    :source,
    extras: %{}
  ]
end
