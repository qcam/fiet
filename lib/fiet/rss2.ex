defmodule Fiet.RSS2 do
  @moduledoc """
  A module to be used to implement RSS 2.0 parser.

  ## Examples

  A RSS 2.0 compliant parser can be implemented with:

      defmodule StandardParser do
        use Fiet.RSS2
      end

  Parsers can also be customized by using `:extras` option, with `:channel` being
  all the outstanding tags in `<channel>` and `:item` being all the outstanding tags in
  `<item>` in the feed.

      defmodule NotSoStardardParser do
        use Fiet.RSS2, [extras: [
          channel: [{"atom:link", "atom:link"}],
          item: [{"content:encoded", "encoded_content"}]
        ]]
      end
  """

  @type t :: %__MODULE__{
          channel: Fiet.RSS2.Channel.t()
        }

  defstruct [:channel]

  alias Fiet.RSS2.{Channel, Item}
  alias Fiet.RSS2

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: Macro.escape(opts)] do
      extras = Keyword.get(opts, :extras, [])
      extra_item_tags = Keyword.get(extras, :item, [])
      extra_channel_tags = Keyword.get(extras, :channel, [])

      def parse(document) do
        {:ok, %RSS2{channel: channel} = feed} =
          Fiet.StackParser.parse(document, %RSS2{}, __MODULE__)

        channel = %{channel | items: Enum.reverse(channel.items)}

        {:ok, %{feed | channel: channel}}
      end

      def on_start_element({"channel", _, _}, stack, feed) do
        channel = %Channel{items: [], extras: %{}}

        %{feed | channel: channel}
      end

      def on_start_element({"item", _, _}, stack, %RSS2{channel: channel} = feed) do
        items = channel.items
        channel = %{channel | items: [%Item{extras: %{}} | items]}

        %{feed | channel: channel}
      end

      def on_start_element(_element, _stack, feed) do
        feed
      end

      def on_end_element(element, [{"channel", _, _} | _], %RSS2{channel: channel} = feed) do
        %{feed | channel: maybe_enrich_channel(element, channel)}
      end

      def on_end_element(element, [{"item", _, _} | _], %RSS2{channel: channel} = feed) do
        [item | items] = channel.items
        item = maybe_enrich_item(element, item)
        channel = %{channel | items: [item | items]}

        %{feed | channel: channel}
      end

      def on_end_element(_element, _stack, state) do
        state
      end

      @channel_tags [
        {"title", :title},
        {"link", :link},
        {"description", :description},
        {"language", :language},
        {"copyright", :copyright},
        {"managingEditor", :managing_editor},
        {"webMaster", :web_master},
        {"pubDate", :pub_date},
        {"lastBuildDate", :last_build_date},
        {"category", :category},
        {"generator", :generator},
        {"docs", :docs},
        {"cloud", :cloud},
        {"ttl", :ttl},
        {"image", :image},
        {"rating", :rating},
        {"skipHours", :skip_hours},
        {"skipDays", :skip_days}
      ]

      Enum.each(@channel_tags, fn {tag_name, key} ->
        defp maybe_enrich_channel({unquote(tag_name), _, content}, channel) do
          Map.put(channel, unquote(key), content)
        end
      end)

      Enum.each(extra_channel_tags, fn {tag_name, key} ->
        defp maybe_enrich_channel({unquote(tag_name), attributes, content}, channel) do
          extras = Map.put(channel.extras, unquote(key), {attributes, content})

          %{channel | extras: extras}
        end
      end)

      defp maybe_enrich_channel(_element, channel), do: channel

      @item_tags [
        {"title", :title},
        {"link", :link},
        {"description", :description},
        {"author", :author},
        {"category", :category},
        {"comments", :comments},
        {"enclosure", :enclosure},
        {"guid", :guid},
        {"pubDate", :pub_date},
        {"source", :source}
      ]

      Enum.each(@item_tags, fn {tag_name, key} ->
        defp maybe_enrich_item({unquote(tag_name), _, content}, item) do
          Map.put(item, unquote(key), content)
        end
      end)

      Enum.each(extra_item_tags, fn {tag_name, key} ->
        defp maybe_enrich_item(
               {unquote(tag_name), attributes, content},
               %Item{extras: extras} = item
             ) do
          extras = Map.put(extras, unquote(key), {attributes, content})
          Map.put(item, :extras, extras)
        end
      end)

      defp maybe_enrich_item(_stack, item) do
        item
      end
    end
  end

  @doc """
  Parses RSS 2.0 document.

  This function accepts RSS 2.0 document in raw binary and returns `{:ok, Fiet.RSS2.t()}`,
  `{:error, any}` otherwise.
  """
  @callback parse(document :: binary) :: {:ok, Fiet.RSS2.t()} | {:error, any}
end
