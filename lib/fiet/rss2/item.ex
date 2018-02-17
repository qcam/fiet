defmodule Fiet.RSS2.Item do
  @moduledoc """
  A struct that represents <item> in RSS 2.0.
  """

  @type t :: %__MODULE__{
          title: binary,
          link: binary,
          description: binary,
          author: binary,
          category: binary,
          comments: binary,
          enclosure: binary,
          guid: binary,
          pub_date: binary,
          source: binary,
          extras: map
        }

  defstruct [
    :title,
    :link,
    :description,
    :author,
    :category,
    :comments,
    :enclosure,
    :guid,
    :pub_date,
    :source,
    :extras
  ]
end
