defmodule Fiet.RSS2.Engine do
  defmodule ParsingError do
    defexception [:reason]

    def message(%__MODULE__{reason: reason}) do
      format_message(reason)
    end

    defp format_message({:not_atom, root_tag}) do
      "unexpected root tag #{inspect(root_tag)}, expected \"rss\""
    end
  end

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

  alias Fiet.RSS2

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: Macro.escape(opts)], location: :keep do
      extras = Keyword.get(opts, :extras, [])
      extra_item_tags = Keyword.get(extras, :item, [])
      extra_channel_tags = Keyword.get(extras, :channel, [])

      def parse(document) do
        case Fiet.StackParser.parse(document, %{channel: %RSS2.Channel{}}, __MODULE__) do
          {:ok, %{channel: channel} = feed} ->
            channel = %{channel | items: Enum.reverse(channel.items)}
            {:ok, channel}

          {:ok, {:not_rss2, _root_tag} = reason} ->
            {:error, %ParsingError{reason: reason}}
        end
      end

      def handle_event(:start_element, {root_tag, _, _}, [], feed) when root_tag != "rss" do
        {:stop, {:not_rss2, root_tag}}
      end

      def handle_event(:start_element, {"channel", _, _}, stack, feed) do
        channel = %RSS2.Channel{}

        %{feed | channel: channel}
      end

      def handle_event(:start_element, {"item", _, _}, _stack, %{channel: channel} = feed) do
        %RSS2.Channel{items: items} = channel
        channel = %{channel | items: [%RSS2.Item{extras: %{}} | items]}

        %{feed | channel: channel}
      end

      def handle_event(:start_element, _element, _stack, feed) do
        feed
      end

      def handle_event(
            :end_element,
            element,
            [{"image", _, _} | [{"channel", _, _} | _]],
            %{channel: channel} = feed
          ) do
        %RSS2.Channel{
          image: image
        } = channel

        image = image || %RSS2.Image{}

        image = maybe_enrich_image(element, image)
        channel = Map.put(channel, :image, image)

        %{feed | channel: channel}
      end

      def handle_event(:end_element, element, [{"channel", _, _} | _], %{channel: channel} = feed) do
        %{feed | channel: maybe_enrich_channel(element, channel)}
      end

      def handle_event(:end_element, element, [{"item", _, _} | _], %{channel: channel} = feed) do
        %RSS2.Channel{
          items: [item | items]
        } = channel

        item = maybe_enrich_item(element, item)
        channel = Map.put(channel, :items, [item | items])

        %{feed | channel: channel}
      end

      def handle_event(:end_element, element, _stack, feed) do
        feed
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
        {"generator", :generator},
        {"docs", :docs},
        {"ttl", :ttl},
        {"rating", :rating},
        {"skipHours", :skip_hours},
        {"skipDays", :skip_days}
      ]

      Enum.each(@channel_tags, fn {tag_name, key} ->
        defp maybe_enrich_channel({unquote(tag_name), _, content}, channel) do
          Map.put(channel, unquote(key), content)
        end
      end)

      defp maybe_enrich_channel({"category", _, _} = element, channel) do
        %{categories: categories} = channel
        {domain, value} = extract_category(element)
        category = %RSS2.Category{domain: domain, value: value}

        %{channel | categories: [category | categories]}
      end

      defp maybe_enrich_channel({"cloud", attributes, _} = element, channel) do
        domain = get_attribute_value(attributes, "domain")
        port = get_attribute_value(attributes, "port")
        path = get_attribute_value(attributes, "path")
        register_procedure = get_attribute_value(attributes, "register_procedure")
        protocol = get_attribute_value(attributes, "protocol")

        cloud = %RSS2.Channel.Cloud{
          domain: domain,
          port: port,
          path: path,
          register_procedure: register_procedure,
          protocol: protocol
        }

        %{channel | cloud: cloud}
      end

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
        {"comments", :comments},
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
               %RSS2.Item{extras: extras} = item
             ) do
          extras = Map.put(extras, unquote(key), {attributes, content})
          Map.put(item, :extras, extras)
        end
      end)

      defp maybe_enrich_item({"category", _, _} = element, item) do
        %{categories: categories} = item
        {domain, value} = extract_category(element)
        category = %RSS2.Category{domain: domain, value: value}

        %{item | categories: [category | categories]}
      end

      defp maybe_enrich_item({"enclosure", attributes, _} = element, channel) do
        length = get_attribute_value(attributes, "length")
        type = get_attribute_value(attributes, "type")
        url = get_attribute_value(attributes, "url")

        enclosure = %RSS2.Item.Enclosure{
          length: length,
          type: type,
          url: url
        }

        %{channel | enclosure: enclosure}
      end

      defp maybe_enrich_item(_tag, item) do
        item
      end

      @image_tags [
        {"title", :title},
        {"link", :link},
        {"description", :description},
        {"url", :url},
        {"width", :width},
        {"height", :height}
      ]

      Enum.each(@image_tags, fn {tag_name, key} ->
        defp maybe_enrich_image({unquote(tag_name), _, content}, image) do
          Map.put(image, unquote(key), content)
        end
      end)

      defp maybe_enrich_image(_tag, image) do
        image
      end

      defp extract_category({"category", attributes, content}) do
        domain = get_attribute_value(attributes, "domain")

        {domain, content}
      end

      defp get_attribute_value(attributes, name) do
        for({key, value} <- attributes, key == name, do: value)
        |> List.first()
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
