defmodule Fiet.RSS2.Image do
  @type t :: %__MODULE__{
          url: binary,
          title: binary,
          link: binary,
          width: binary,
          height: binary,
          description: binary
        }

  defstruct [:url, :title, :link, :width, :height, :description]
end
