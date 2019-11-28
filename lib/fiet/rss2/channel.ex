defmodule Fiet.RSS2.Channel do
  defmodule Cloud do
    @type t :: %__MODULE__{
            domain: binary | nil,
            port: binary | nil,
            path: binary | nil,
            register_procedure: binary | nil,
            protocol: binary | nil
          }

    defstruct [:domain, :port, :path, :register_procedure, :protocol]
  end

  @moduledoc """
  A struct that represents `<channel>` in RSS 2.0.

  ### extras attribute

  `Fiet.RSS2.Channel` contains an `extras` attribute which can be used to store
  extra data provided by the feeds (which don't strictly follow RSS 2.0 specs).
  See `Fiet.RSS2.Engine` for more information.

  """

  @type t :: %__MODULE__{
          title: binary | nil,
          link: binary | nil,
          description: binary | nil,
          language: binary | nil,
          copyright: binary | nil,
          managing_editor: binary | nil,
          web_master: binary | nil,
          pub_date: binary | nil,
          last_build_date: binary | nil,
          categories: list(Fiet.RSS2.Category.t()),
          generator: binary | nil,
          docs: binary | nil,
          cloud: Cloud.t() | nil,
          ttl: binary | nil,
          image: Fiet.RSS2.Image.t() | nil,
          rating: binary | nil,
          items: list(Fiet.RSS2.Item.t()),
          extras: map()
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
    :generator,
    :docs,
    :cloud,
    :ttl,
    :image,
    :rating,
    :skip_hours,
    :skip_days,
    categories: [],
    items: [],
    extras: %{}
  ]
end
