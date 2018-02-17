# Fiết

An extendable feeds parser in Elixir.

## Installation

```elixir
def deps do
  [{:fiet, "~> 0.1.0"}]
end
```

## Overview

Full documentation can be found on [HexDocs](https://hexdocs.pm/fiet).

### RSS 2.0

If the feed you are parsing complies with [RSS 2.0](http://cyber.harvard.edu/rss/rss.html), a standard parser can be implemented with:

```elixir
defmodule StandardParser do
  use Fiet.RSS2
end

iex> NormalParser.parse(rss)
{:ok,
 %Fiet.RSS2{
   channel: %Fiet.RSS2.Channel{
     category: nil,
     cloud: nil,
     copyright: nil,
     description: "Liftoff to Space Exploration.",
     docs: "http://blogs.law.harvard.edu/tech/rss",
     extras: %{},
     generator: "Weblog Editor 2.0",
     image: nil,
     language: "en-us",
     last_build_date: "Tue, 10 Jun 2003 09:41:01 GMT",
     link: "http://liftoff.msfc.nasa.gov/",
     managing_editor: "editor@example.com",
     pub_date: "Tue, 10 Jun 2003 04:00:00 GMT",
     rating: nil,
     skip_days: nil,
     skip_hours: nil,
     text_input: nil,
     title: "Liftoff News",
     ttl: nil,
     web_master: "webmaster@example.com"
     items: [
       %Fiet.RSS2.Item{
         author: nil,
         category: nil,
         comments: nil,
         description: "How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's &lt;a href=\"http://howe.iki.rssi.ru/GCTC/gctc_e.htm\"&gt;Star City&lt;/a&gt;.",
         enclosure: nil,
         extras: %{},
         guid: "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573",
         link: "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp",
         pub_date: "Tue, 03 Jun 2003 09:39:21 GMT",
         source: nil,
         title: "Star City"
       },
       ...
     ]
   }
 }
```

Fiet also supports parsing non-standard tags in the feed with `:extras` option.

```elixir
defmodule OutstandingFeed do
  use Fiet.RSS2, extras: [
    channel: [{"atom:link", "atom:link"}],
    item: [{"content:encoded", "encoded_content"}]
  ]
end
```

## Why is it called "Fiết"?

First of all, all the good names are taken.

"Fiết", an hybrid Vietnamese word which is pronounced as "Feed".

## Contributing

1. Fork it.
2. Write code and related tests.
3. Send a pull request.
