defmodule Viet.RSS2.Item do
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
