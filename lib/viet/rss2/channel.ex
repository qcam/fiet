defmodule Viet.RSS2.Channel do
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
