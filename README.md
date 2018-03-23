# Fiết

An extendable feeds parser in Elixir.

## Installation

```elixir
def deps do
  [{:fiet, "~> 0.2.1"}]
end
```

## Overview

Full documentation can be found on [HexDocs](https://hexdocs.pm/fiet).

Current Fiết supports two feed formats: [Atom - RFC 4287](https://tools.ietf.org/html/rfc4287) and [RSS 2.0](cyber.harvard.edu/rss/rss.html).

To start parsing, go:

```elixir
iex> Fiet.parse(File.read!("/path/to/rss.xml"))
{:ok,
 %Fiet.Feed{
   categories: ["Science", "Space"],
   description: "Liftoff to Space Exploration.",
   items: [
     %Fiet.Item{
       description: "How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's &lt;a href=\"http://howe.iki.rssi.ru/GCTC/gctc_e.htm\"&gt;Star City&lt;/a&gt;.",
       id: "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573",
       link: "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp",
       published_at: "Tue, 03 Jun 2003 09:39:21 GMT",
       title: "Star City"
     },
     %Fiet.Item{
       description: "Sky watchers in Europe, Asia, and parts of Alaska and Canada will experience a &lt;a href=\"http://science.nasa.gov/headlines/y2003/30may_solareclipse.htm\"&gt;partial eclipse of the Sun&lt;/a&gt; on Saturday, May 31st.",
       id: "http://liftoff.msfc.nasa.gov/2003/05/30.html#item572",
       link: nil,
       published_at: "Fri, 30 May 2003 11:06:42 GMT",
       title: "It looks cool"
     }
   ],
   link: "http://liftoff.msfc.nasa.gov/",
   title: "Liftoff News",
   updated_at: "Tue, 10 Jun 2003 09:41:01 GMT"
 }}
```

Fiết also supports customized RSS 2.0, in case the feed document does not strictly follow the specs. See full documentation for more information on [HexDocs](https://hexdocs.pm/fiet).

## Why is it called "Fiết"?

To be honest, all the good names had been taken.

"Fiết", a not-so-Vietnamese word that's pronounced 90% like "feed".

## Contributing

1. Fork it.
2. Write code and related tests.
3. Send a pull request.
