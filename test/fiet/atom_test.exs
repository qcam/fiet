defmodule Fiet.AtomTest do
  use ExUnit.Case, async: true

  alias Fiet.Atom

  test "parse/1 with simple Atom feed" do
    atom = File.read!("./test/support/fixture/simple.atom.xml")

    {:ok, feed} = Atom.parse(atom)

    assert %Atom.Feed{
             title: {:text, title},
             links: [alternate_link, self_link],
             categories: [space_category, science_category],
             updated: updated,
             generator: generator,
             rights: {:text, rights},
             subtitle: {:html, subtitle},
             entries: [entry]
           } = feed

    assert title == "dive into mark"

    assert subtitle ==
             "\n       A <em>lot</em> of effort\n       went into making this effortless\n     "

    assert self_link == %Fiet.Atom.Link{
             href: "http://example.org/feed.atom",
             href_lang: nil,
             length: nil,
             rel: "self",
             title: nil,
             type: "application/atom+xml"
           }

    assert alternate_link == %Fiet.Atom.Link{
             href: "http://example.org/",
             href_lang: "en",
             length: nil,
             rel: "alternate",
             title: nil,
             type: "text/html"
           }

    assert space_category == %Fiet.Atom.Category{
             label: "Space",
             term: "space",
             scheme: nil
           }

    assert science_category == %Fiet.Atom.Category{
             label: "Science",
             term: "science",
             scheme: nil
           }

    assert updated == "2005-07-31T12:29:29Z"

    assert generator == %Fiet.Atom.Generator{
             text: "\n       Example Toolkit\n     ",
             uri: "http://www.example.com/",
             version: "1.0"
           }

    assert rights == "Copyright (c) 2003, Mark Pilgrim"

    assert %Fiet.Atom.Entry{
             id: "tag:example.org,2003:3.2397",
             title: {:text, "Atom draft-07 snapshot"},
             updated: "2005-07-31T12:29:29Z",
             links: [enclosure_link, alternate_link],
             published: "2003-12-13T08:29:29-04:00",
             summary: nil,
             content: {:text, "Test Content"},
             rights: {:xhtml, :skipped},
             categories: [],
             authors: [author],
             contributors: [joe, sam]
           } = entry

    assert enclosure_link ==
             %Fiet.Atom.Link{
               href: "http://example.org/audio/ph34r_my_podcast.mp3",
               href_lang: nil,
               length: "1337",
               rel: "enclosure",
               title: nil,
               type: "audio/mpeg"
             }

    assert alternate_link ==
             %Fiet.Atom.Link{
               href: "http://example.org/2005/04/02/atom",
               href_lang: nil,
               length: nil,
               rel: "alternate",
               title: nil,
               type: "text/html"
             }

    assert author ==
             %Fiet.Atom.Person{
               email: "f8dy@example.com",
               name: "Mark Pilgrim",
               uri: "http://example.org/"
             }

    assert joe == %Fiet.Atom.Person{
             email: nil,
             name: "Joe Gregorio",
             uri: nil
           }

    assert sam == %Fiet.Atom.Person{
             email: nil,
             name: "Sam Ruby",
             uri: nil
           }
  end

  test "parse/1 with complex atom feed" do
    atom = File.read!("./test/support/fixture/complex.atom.xml")

    {:ok, feed} = Atom.parse(atom)

    %Atom.Feed{title: title, entries: entries} = feed

    assert title == {:text, "World News"}

    assert length([entry | _] = entries) == 25

    assert %Atom.Entry{
             title: title,
             links: [link],
             updated: updated
           } = entry

    assert title ==
             {:text, "8000-yr old underwater burial site reveals human skulls mounted on poles"}

    assert link == %Fiet.Atom.Link{
             href:
               "https://www.reddit.com/r/worldnews/comments/7yo6hx/8000yr_old_underwater_burial_site_reveals_human/",
             href_lang: nil,
             length: nil,
             rel: nil,
             title: nil,
             type: nil
           }

    assert updated == "2018-02-19T17:10:48+00:00"
  end

  test "parse/1 with a non-Atom feed" do
    non_atom = """
    <?xml version="1.0" ?>
    <foo></foo>
    """

    assert {:error, reason} = Atom.parse(non_atom)
    assert reason == %Fiet.Atom.ParsingError{reason: {:not_atom, "foo"}}
  end
end
