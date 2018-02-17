defmodule Fiet.RSS2.Channel do
  @moduledoc """
  A struct that represents `<channel>` in RSS 2.0.
  """

  @type t :: %__MODULE__{
          title: binary,
          link: binary,
          description: binary,
          language: binary,
          copyright: binary,
          managing_editor: binary,
          web_master: binary,
          pub_date: binary,
          last_build_date: binary,
          category: binary,
          generator: binary,
          docs: binary,
          cloud: binary,
          ttl: binary,
          image: binary,
          rating: binary,
          text_input: binary,
          skip_hours: binary,
          skip_days: binary,
          items: binary,
          extras: map
        }

  defstruct [
    :title,
    :link,
    :description,
    :language,
    :copyright,
    :managing_editor,
    :web_master,
    :pub_date,
    :last_build_date,
    :category,
    :generator,
    :docs,
    :cloud,
    :ttl,
    :image,
    :rating,
    :text_input,
    :skip_hours,
    :skip_days,
    :items,
    :extras
  ]
end
