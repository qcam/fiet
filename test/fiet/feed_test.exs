defmodule Fiet.FeedTest do
  use ExUnit.Case, async: true

  alias Fiet.{Atom, RSS2}

  test "new/1 for Atom feed" do
    atom_feed = %Atom.Feed{
      title: {:text, "title"},
      subtitle: {:text, "subtitle"},
      links: [
        %Atom.Link{
          href: "https://example.com",
          rel: "self"
        }
      ],
      updated: "2018-01-0111:40:41+00:00",
      categories: [
        %Atom.Category{term: "science"},
        %Atom.Category{term: "space"}
      ],
      entries: [
        %Atom.Entry{
          id: "1",
          title: {:text, "item 1"},
          summary: {:text, "item 1 summary"},
          links: [
            %Atom.Link{
              href: "https://example.com/item/1"
            }
          ],
          published: "2018-01-0111:40:41+00:00"
        },
        %Atom.Entry{
          id: "2",
          title: {:text, "item 2"},
          summary: {:text, "item 2 summary"},
          links: [
            %Atom.Link{
              href: "https://example.com/item/2"
            }
          ],
          updated: "2018-01-0111:40:41+00:00"
        }
      ]
    }

    assert %Fiet.Feed{
             title: "title",
             description: "subtitle",
             link: "https://example.com",
             updated_at: "2018-01-0111:40:41+00:00",
             categories: ["science", "space"],
             items: [item1, item2]
           } = Fiet.Feed.new(atom_feed)

    assert item1 == %Fiet.Item{
             id: "1",
             title: "item 1",
             description: "item 1 summary",
             link: "https://example.com/item/1",
             published_at: "2018-01-0111:40:41+00:00"
           }

    assert item2 == %Fiet.Item{
             id: "2",
             title: "item 2",
             description: "item 2 summary",
             link: "https://example.com/item/2",
             published_at: "2018-01-0111:40:41+00:00"
           }
  end

  test "new/1 for RSS2 feed" do
    atom_feed = %RSS2.Channel{
      title: "title",
      description: "description",
      link: "https://example.com",
      last_build_date: "Sat, 07 Sep 2002 00:00:01 GMT",
      categories: [
        %RSS2.Category{value: "science"},
        %RSS2.Category{value: "space"}
      ],
      items: [
        %RSS2.Item{
          guid: "item-1",
          title: "item 1",
          description: "item 1 summary",
          link: "https://example.com/item/1",
          pub_date: "Sat, 07 Sep 2002 00:00:01 GMT"
        }
      ]
    }

    assert %Fiet.Feed{
             title: "title",
             description: "description",
             link: "https://example.com",
             updated_at: "Sat, 07 Sep 2002 00:00:01 GMT",
             categories: ["science", "space"],
             items: [item]
           } = Fiet.Feed.new(atom_feed)

    assert item == %Fiet.Item{
             id: "item-1",
             title: "item 1",
             description: "item 1 summary",
             link: "https://example.com/item/1",
             published_at: "Sat, 07 Sep 2002 00:00:01 GMT"
           }
  end
end
