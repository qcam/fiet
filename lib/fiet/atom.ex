defmodule Fiet.Atom do
  @moduledoc """
  Atom parser, comply with [RFC 4287](https://tools.ietf.org/html/rfc4287).

  ## Text constructs

  Fiet supports two out of three text contructs in Atom: `text` and `html`.
  `xhtml` is not supported.

  In text constructs fields, the returning format is `{format, data}`. If "type"
  attribute does not exist in the tag, format will be `text` by default.

  For example, `<title type="html">Less: &lt;em> &amp;lt; &lt;/em></title>` will
  give you `{:html, "Less: &lt;em> &amp;lt; &lt;/em>"}`.

  ## Person constructs

  There are three attributes in Person construct: name, uri and email, both
  contributors and authors returned by the parser will be in `Fiet.Atom.Person`
  struct.

  See `Fiet.Atom.Person` for more information.

  """

  alias Fiet.Atom

  defmodule ParsingError do
    defexception [:reason]

    def message(%__MODULE__{reason: reason}) do
      {error_type, term} = reason

      format_message(error_type, term)
    end

    defp format_message(:not_atom, root_tag) do
      "unexpected root tag #{inspect(root_tag)}, expected \"feed\""
    end
  end

  @doc """
  Parses Atom document feed.

  ## Example

      iex> Fiet.Atom.parse(atom)
      {:ok,
      %Fiet.Atom.Feed{
        authors: [],
        categories: [
         %Fiet.Atom.Category{label: "Space", scheme: nil, term: "space"},
         %Fiet.Atom.Category{label: "Science", scheme: nil, term: "science"}
        ],
        contributors: [],
        entries: [
         %Fiet.Atom.Entry{
           authors: [
             %Fiet.Atom.Person{
               email: "john.doe@example.com",
               name: "John Doe",
               uri: "http://example.org/"
             }
           ],
           categories: [],
           content: {:text, "Test Content"},
           contributors: [
             %Fiet.Atom.Person{email: nil, name: "Joe Gregorio", uri: nil},
             %Fiet.Atom.Person{email: nil, name: "Sam Ruby", uri: nil}
           ],
           id: "tag:example.org,2003:3.2397",
           link: %Fiet.Atom.Link{
             href: "http://example.org/audio/ph34r_my_podcast.mp3",
             href_lang: nil,
             length: "1337",
             rel: "enclosure",
             title: nil,
             type: "audio/mpeg"
           },
           published: nil,
           rights: {:xhtml, :skipped},
           source: nil,
           summary: nil,
           title: {:text, "Atom draft-07 snapshot"},
           updated: "2005-07-31T12:29:29Z"
         }
        ],
        generator: %Fiet.Atom.Generator{
         text: "\n       Example Toolkit\n     ",
         uri: "http://www.example.com/",
         version: "1.0"
        },
        icon: nil,
        id: "tag:example.org,2003:3",
        link: %Fiet.Atom.Link{
         href: "http://example.org/feed.atom",
         href_lang: nil,
         length: nil,
         rel: "self",
         title: nil,
         type: "application/atom+xml"
        },
        logo: nil,
        rights: {:text, "Copyright (c) 2003, Mark Pilgrim"},
        subtitle: {:html,
        "\n       A &lt;em&gt;lot&lt;/em&gt; of effort\n       went into making this effortless\n     "},
        title: {:text, "dive into mark"},
        updated: "2005-07-31T12:29:29Z"
      }}
  """

  def parse(document) when is_binary(document) do
    try do
      Fiet.StackParser.parse(document, %Atom.Feed{}, __MODULE__)
    rescue
      exception in ParsingError ->
        {:error, exception.reason}
    else
      {:ok, %Atom.Feed{} = feed} ->
        {:ok, feed}

      {:ok, {:not_atom, _root_tag} = reason} ->
        {:error, %ParsingError{reason: reason}}

      {:error, _reason} = error ->
        error
    end
  end

  @doc false

  def handle_event(:start_element, {root_tag, _, _}, [], _feed) when root_tag != "feed" do
    {:stop, {:not_atom, root_tag}}
  end

  def handle_event(:start_element, {"entry", _, _}, [{"feed", _, _} | []], feed) do
    %{entries: entries} = feed

    %{feed | entries: [%Atom.Entry{} | entries]}
  end

  def handle_event(:end_element, {"entry", _, _}, [{"feed", _, _} | []], feed) do
    %{
      links: links,
      entries: entries,
      categories: categories,
      authors: authors,
      contributors: contributors
    } = feed

    %{
      feed
      | links: Enum.reverse(links),
        entries: Enum.reverse(entries),
        categories: Enum.reverse(categories),
        authors: Enum.reverse(authors),
        contributors: Enum.reverse(contributors)
    }
  end

  @people_tags [
    {"author", :authors},
    {"contributor", :contributors}
  ]

  @person_tags [
    {"name", :name},
    {"email", :email},
    {"uri", :uri}
  ]

  Enum.each(@people_tags, fn {people_tag, people_key} ->
    def handle_event(:start_element, {unquote(people_tag), _, _}, [{"feed", _, _} | _], feed) do
      people = [%Atom.Person{} | feed.unquote(people_key)]

      Map.put(feed, unquote(people_key), people)
    end

    def handle_event(:start_element, {unquote(people_tag), _, _}, [{"entry", _, _} | _], feed) do
      [entry | entries] = feed.entries

      people = [%Atom.Person{} | entry.unquote(people_key)]

      entry = Map.put(entry, unquote(people_key), people)

      %{feed | entries: [entry | entries]}
    end

    Enum.each(@person_tags, fn {person_tag, person_key} ->
      def handle_event(
            :end_element,
            {unquote(person_tag), _, content},
            [{unquote(people_tag), _, _} | [{"feed", _, _} | _]],
            feed
          ) do
        [person | people] = feed.unquote(people_key)

        person = Map.put(person, unquote(person_key), content)

        Map.put(feed, unquote(people_key), [person | people])
      end

      def handle_event(
            :end_element,
            {unquote(person_tag), _, content},
            [{unquote(people_tag), _, _} | [{"entry", _, _} | _]],
            feed
          ) do
        [entry | entries] = feed.entries
        [person | people] = entry.unquote(people_key)

        person = Map.put(person, unquote(person_key), content)
        entry = Map.put(entry, unquote(people_key), [person | people])

        %{feed | entries: [entry | entries]}
      end
    end)
  end)

  def handle_event(:start_element, _element, _stack, feed) do
    feed
  end

  @feed_simple_tags [
    {"id", :id},
    {"updated", :updated},
    {"logo", :logo},
    {"icon", :icon}
  ]

  Enum.each(@feed_simple_tags, fn {feed_tag, feed_key} ->
    def handle_event(:end_element, {unquote(feed_tag), _, content}, [{"feed", _, _} | _], feed) do
      Map.put(feed, unquote(feed_key), content)
    end
  end)

  def handle_event(:end_element, {"category", _, _} = element, [{"feed", _, _} | _], feed) do
    category = Atom.Category.from_element(element)

    %{feed | categories: [category | feed.categories]}
  end

  def handle_event(:end_element, {"link", _, _} = element, [{"feed", _, _} | _], feed) do
    %{links: links} = feed

    link = Atom.Link.from_element(element)

    %{feed | links: [link | links]}
  end

  def handle_event(:end_element, {"generator", _, _} = element, [{"feed", _, _} | _], feed) do
    generator = Atom.Generator.from_element(element)

    %{feed | generator: generator}
  end

  @entry_simple_tags [
    {"id", :id},
    {"published", :published},
    {"updated", :updated}
  ]

  Enum.each(@entry_simple_tags, fn {tag_name, key} ->
    def handle_event(:end_element, {unquote(tag_name), _, content}, [{"entry", _, _} | _], feed) do
      %{entries: [entry | entries]} = feed

      entry = Map.put(entry, unquote(key), content)

      %{feed | entries: [entry | entries]}
    end
  end)

  @feed_text_construct_tags [
    {"title", :title},
    {"subtitle", :subtitle},
    {"rights", :rights}
  ]

  Enum.each(@feed_text_construct_tags, fn {tag_name, key} ->
    def handle_event(
          :end_element,
          {unquote(tag_name), attributes, content},
          [{"feed", _, _} | _],
          feed
        ) do
      case extract_text(attributes, content) do
        {:ok, content} ->
          Map.put(feed, unquote(key), content)

        {:error, _reason} ->
          feed
      end
    end
  end)

  @entry_text_construct_tags [
    {"title", :title},
    {"summary", :summary},
    {"content", :content},
    {"rights", :rights}
  ]

  Enum.each(@entry_text_construct_tags, fn {tag_name, key} ->
    def handle_event(
          :end_element,
          {unquote(tag_name), attributes, content},
          [{"entry", _, _} | _],
          feed
        ) do
      case extract_text(attributes, content) do
        {:ok, content} ->
          %{entries: [entry | entries]} = feed

          entry = Map.put(entry, unquote(key), content)

          %{feed | entries: [entry | entries]}

        {:error, _reason} ->
          feed
      end
    end
  end)

  def handle_event(:end_element, {"link", _, _} = element, [{"entry", _, _} | _], feed) do
    %{entries: [entry | entries]} = feed
    %{links: links} = entry

    link = Atom.Link.from_element(element)
    entry = Map.put(entry, :links, [link | links])

    %{feed | entries: [entry | entries]}
  end

  def handle_event(:end_element, _element, _stack, feed) do
    feed
  end

  defp extract_text(attributes, content) do
    case get_attribute_value(attributes, "type") do
      type when is_nil(type) or type == "text" ->
        {:ok, {:text, content}}

      "html" ->
        {:ok, {:html, content}}

      "xhtml" ->
        {:ok, {:xhtml, :skipped}}

      type ->
        {:error, "type #{inspect(type)} is not supported"}
    end
  end

  defp get_attribute_value(attributes, name) do
    for({key, value} <- attributes, key == name, do: value)
    |> List.first()
  end
end
