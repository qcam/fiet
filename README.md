# Viet

An extendable RSS2.0 parser in Elixir, powered by erlsom.

## Usage

WIP, Proper documentation will come later.

To use the default parser.

```elixir
defmodule NormalParser do
  use Viet.RSS2
end

NormalParser.parse(rss)
```

Since RSS is a mess, 90% of the time you need to some outstanding parser, do
this:

```elixir
defmodule OutstandingFeed do
  use Viet.RSS2, extras: [
    channel: [{{'prefix', 'realTag'}, "my-key"}],
    item: [{'aNonStandardTag', "standard"}]
  ]
end
```
