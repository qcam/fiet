defmodule Fiet.RSS2Test do
  use ExUnit.Case, async: true

  alias Fiet.RSS2

  test "parse/1 with standard parser" do
    rss = File.read!("./test/support/fixture/simple.rss.xml")

    {:ok, channel} = RSS2.parse(rss)

    %RSS2.Channel{
      title: title,
      link: link,
      description: description,
      last_build_date: last_build_date,
      categories: categories,
      image: image,
      items: items
    } = channel

    assert title == "Liftoff News"
    assert link == "http://liftoff.msfc.nasa.gov/"
    assert description == "Liftoff to Space Exploration."
    assert last_build_date == "Tue, 10 Jun 2003 09:41:01 GMT"

    assert length(categories) == 2

    assert [category | categories] = categories

    assert category ==
             %RSS2.Category{domain: "https://example.com/categories/science", value: "Science"}

    assert [category] = categories
    assert category == %RSS2.Category{domain: nil, value: "Space"}

    %RSS2.Image{
      title: channel_image_title,
      link: channel_image_link,
      url: channel_image_url,
      description: channel_image_description,
      width: channel_image_width,
      height: channel_image_height
    } = image

    assert channel_image_title == "Liftoff News Logo"
    assert channel_image_link == "https://www.liftoff.msfc.nasa.gov/"
    assert channel_image_url == "https://www.example.com/images/logo.png"
    assert channel_image_description == "The logo of Liftoff News"
    assert channel_image_width == "50"
    assert channel_image_height == "50"

    assert [item | _] = items

    %RSS2.Item{
      title: item_title,
      link: item_link,
      description: item_description,
      enclosure: item_enclosure
    } = item

    assert item_title == "Star City"
    assert item_link == "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp"

    assert item_description ==
             "How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's &lt;a href=\"http://howe.iki.rssi.ru/GCTC/gctc_e.htm\"&gt;Star City&lt;/a&gt;."

    assert item_enclosure == %RSS2.Item.Enclosure{
             length: "78645",
             type: "video/wmv",
             url: "https://www.w3schools.com/media/3d.wmv"
           }
  end

  test "parse/1 with non RSS 2.0 feed" do
    rss = """
    <?xml version="1.0" encoding="UTF-8"?>
    <foo></foo>
    """

    assert {:error, reason} = RSS2.parse(rss)
    assert reason == %RSS2.Engine.ParsingError{reason: {:not_rss2, "foo"}}
  end
end
