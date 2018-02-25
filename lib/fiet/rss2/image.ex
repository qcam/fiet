defmodule Fiet.RSS2.Image do
  @type t :: %__MODULE__{
          url: binary | nil,
          title: binary | nil,
          link: binary | nil,
          width: binary | nil,
          height: binary | nil,
          description: binary | nil
        }

  defstruct [:url, :title, :link, :width, :height, :description]
end
