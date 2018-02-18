defmodule Fiet.RSS2.StandardParser do
  use Fiet.RSS2
end

defmodule Fiet.RSS2.OutstandingParser do
  use Fiet.RSS2,
    extras: [
      channel: [{"atom:link", "atom_link"}],
      item: [{"dc:creator", "creator"}]
    ]
end

defmodule Fiet.RSS2Test do
  use ExUnit.Case, async: true

  alias Fiet.RSS2

  test "parse/1 with standard parser" do
    rss = File.read!("./test/support/fixture/simple.rss.xml")

    {:ok, feed} = RSS2.StandardParser.parse(rss)

    %RSS2.Channel{
      title: title,
      link: link,
      description: description,
      last_build_date: last_build_date,
      categories: categories,
      image: image,
      items: items,
    } = feed.channel

    assert title == "Liftoff News"
    assert link == "http://liftoff.msfc.nasa.gov/"
    assert description == "Liftoff to Space Exploration."
    assert last_build_date == "Tue, 10 Jun 2003 09:41:01 GMT"

    assert length(categories) == 2

    assert [category | categories] = categories
    assert category ==
      %RSS2.Category{domain: "https://example.com/categories/science", value: "Science"}

    assert [category] = categories
    assert category ==
      %RSS2.Category{domain: nil, value: "Space"}

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
    assert item_description == "How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's &lt;a href=\"http://howe.iki.rssi.ru/GCTC/gctc_e.htm\"&gt;Star City&lt;/a&gt;."
    assert item_enclosure == %RSS2.Item.Enclosure{
      length: "78645",
      type: "video/wmv",
      url: "https://www.w3schools.com/media/3d.wmv"
    }
  end

  test "parse/1 for customized parser" do
    rss = File.read!("./test/support/fixture/outstanding.rss.xml")

    {:ok, feed} = Fiet.RSS2.OutstandingParser.parse(rss)

    channel = feed.channel
    assert channel.title == "Liftoff News"
    assert channel.link == "http://liftoff.msfc.nasa.gov/"
    assert channel.description == "Liftoff to Space Exploration."
    assert channel.last_build_date == "Tue, 10 Jun 2003 09:41:01 GMT"
    assert {attrs, content} = Map.fetch!(channel.extras, "atom_link")
    assert attrs == [
      {"href", "http://superfeedr.com"},
      {"rel", "hub"}
    ]
    assert content == ""

    assert [item | _] = channel.items
    assert item.title == "Star City"
    assert extras = item.extras
    assert Map.fetch!(extras, "creator") == {[], "John Doe"}
  end

  test "parse/1 with non RSS 2.0 feed" do
    rss = """
    <?xml version="1.0" encoding="UTF-8"?>
    <foo></foo>
    """

    assert {:error, reason} = Fiet.RSS2.StandardParser.parse(rss)
    assert reason == "unexpected root tag \"foo\""
  end
end
