defmodule FietTest do
  use ExUnit.Case, async: true

  test "parse/1" do
    atom = File.read!("./test/support/fixture/simple.atom.xml")

    assert {:ok, %Fiet.Feed{}} = Fiet.parse(atom)

    rss = File.read!("./test/support/fixture/simple.rss.xml")

    assert {:ok, %Fiet.Feed{}} = Fiet.parse(rss)

    invalid_feed = """
    <?xml version="1.0" ?>
    <foo/>
    """

    assert {:error, reason} = Fiet.parse(invalid_feed)
    assert reason == "input data format is not supported"

    invalid_xml = File.read!("./test/support/fixture/jsonfeed.json")
    assert {:error, reason} = Fiet.parse(invalid_xml)
    assert reason == "input data format is not supported"
  end

  test "parse!/1" do
    atom = File.read!("./test/support/fixture/simple.atom.xml")

    assert feed = Fiet.parse!(atom)

    assert %Fiet.Feed{
             title: "dive into mark",
             link: "http://example.org/feed.atom"
           } = feed

    rss = File.read!("./test/support/fixture/simple.rss.xml")

    assert %Fiet.Feed{} = Fiet.parse!(rss)

    non_feed = """
    <?xml version="1.0" ?>
    <foo/>
    """

    assert_raise RuntimeError, "input data format is not supported", fn ->
      Fiet.parse!(non_feed)
    end
  end
end
