defmodule Fiet.RSS2.OutstandingParser do
  use Fiet.RSS2.Engine,
    extras: [
      channel: [{"atom:link", "atom_link"}],
      item: [{"dc:creator", "creator"}]
    ]
end

defmodule Fiet.RSS2.EngineTest do
  use ExUnit.Case, async: true

  test "parse/1 for customized parser" do
    rss = File.read!("./test/support/fixture/outstanding.rss.xml")

    {:ok, channel} = Fiet.RSS2.OutstandingParser.parse(rss)

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
end
