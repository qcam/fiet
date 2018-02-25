defmodule Fiet.RSS2 do
  @moduledoc """
  RSS 2.0 parser, comply with [RSS 2.0 at Harvard Law](http://cyber.harvard.edu/rss/rss.html).
  """

  use Fiet.RSS2.Engine

  @doc """
  Parses RSS 2.0 XML document.

  ## Example

      iex> rss2 = File.read!("/path/to/rss2.xml")
      iex> Fiet.RSS2.parse(rss2)
      {:ok,
        %Fiet.RSS2.Channel{
          categories: [
            %Fiet.RSS2.Category{domain: "https://example.com/categories/science", value: "Science"},
            %Fiet.RSS2.Category{domain: nil, value: "Space"}
          ],
          cloud: %Fiet.RSS2.Channel.Cloud{
            domain: "rpc.sys.com",
            path: "/RPC2",
            port: "80",
            protocol: "xml-rpc",
            register_procedure: nil
          },
          copyright: nil,
          description: "Liftoff to Space Exploration.",
          docs: "http://blogs.law.harvard.edu/tech/rss",
          extras: %{},
          generator: "Weblog Editor 2.0",
          image: %Fiet.RSS2.Image{
            description: "The logo of Liftoff News",
            height: "50",
            link: "https://www.liftoff.msfc.nasa.gov/",
            title: "Liftoff News Logo",
            url: "https://www.example.com/images/logo.png",
            width: "50"
          },
          items: [
            %Fiet.RSS2.Item{
              author: nil,
              categories: [%Fiet.RSS2.Category{domain: nil, value: "Space"} | nil],
              comments: nil,
              description: "How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's &lt;a href=\"http://howe.iki.rssi.ru/GCTC/gctc_e.htm\"&gt;Star City&lt;/a&gt;.",
              enclosure: %Fiet.RSS2.Item.Enclosure{
              length: "78645",
              type: "video/wmv",
              url: "https://www.w3schools.com/media/3d.wmv"
            },
            extras: %{},
            guid: "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573",
            link: "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp",
            pub_date: "Tue, 03 Jun 2003 09:39:21 GMT",
            source: nil,
            title: "Star City"
          }
        }
      }

  """

  @spec parse(document :: binary) :: {:ok, channel :: Fiet.RSS2.Channel.t()}

  def parse(document)
end
