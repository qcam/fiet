defmodule Fiet.Item do
  @type t :: %__MODULE__{
          id: binary | nil,
          title: binary | nil,
          description: binary | nil,
          published_at: binary | nil,
          link: binary | nil
        }

  defstruct [
    :id,
    :title,
    :description,
    :published_at,
    :link
  ]
end
