defmodule Fiet.Atom do
  alias Fiet.Atom

  def parse(document) when is_binary(document) do
    case Fiet.StackParser.parse(document, %Atom.Feed{}, __MODULE__) do
      {:ok, %Atom.Feed{} = feed} ->
        {:ok, feed}

      {:error, _reason} = error ->
        error
    end
  end

  def on_start_element({"entry", _, _}, [{"feed", _, _} | []], feed) do
    %{entries: entries} = feed

    %{feed | entries: [%Atom.Entry{} | entries]}
  end

  def on_end_element({"entry", _, _}, [{"feed", _, _} | []], feed) do
    %{
      entries: entries,
      categories: categories,
      authors: authors,
      contributors: contributors
    } = feed

    %{
      feed
      | entries: Enum.reverse(entries),
        categories: Enum.reverse(categories),
        authors: Enum.reverse(authors),
        contributors: Enum.reverse(contributors),
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
    def on_start_element({unquote(people_tag), _, _}, [{"feed", _, _} | _], feed) do
      people = [%Atom.Person{} | feed.unquote(people_key)]

      Map.put(feed, unquote(people_key), people)
    end

    def on_start_element({unquote(people_tag), _, _}, [{"entry", _, _} | _], feed) do
      [entry | entries] = feed.entries

      people = [%Atom.Person{} | entry.unquote(people_key)]

      entry = Map.put(entry, unquote(people_key), people)

      %{feed | entries: [entry | entries]}
    end

    Enum.each(@person_tags, fn {person_tag, person_key} ->
      def on_end_element(
            {unquote(person_tag), _, content},
            [{unquote(people_tag), _, _} | [{"feed", _, _} | _]],
            feed
          ) do
        [person | people] = feed.unquote(people_key)

        person = Map.put(person, unquote(person_key), content)

        Map.put(feed, unquote(people_key), [person | people])
      end

      def on_end_element(
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

  def on_start_element(_element, _stack, feed) do
    feed
  end

  @feed_simple_tags [
    {"id", :id},
    {"updated", :updated},
    {"logo", :logo},
    {"icon", :icon},
  ]

  Enum.each(@feed_simple_tags, fn {feed_tag, feed_key} ->
    def on_end_element({unquote(feed_tag), _, content}, [{"feed", _, _} | _], feed) do
      Map.put(feed, unquote(feed_key), content)
    end
  end)

  def on_end_element({"category", _, _} = element, [{"feed", _, _} | _], feed) do
    category = Atom.Category.from_element(element)

    %{feed | categories: [category | feed.categories]}
  end

  def on_end_element({"link", _, _} = element, [{"feed", _, _} | _], feed) do
    link = Atom.Link.from_element(element)

    %{feed | link: link}
  end

  def on_end_element({"generator", _, _} = element, [{"feed", _, _} | _], feed) do
    generator = Atom.Generator.from_element(element)

    %{feed | generator: generator}
  end

  @entry_simple_tags [
    {"id", :id},
    {"updated", :updated},
  ]

  Enum.each(@entry_simple_tags, fn {tag_name, key} ->
    def on_end_element({unquote(tag_name), _, content}, [{"entry", _, _} | _], feed) do
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
    def on_end_element({unquote(tag_name), attributes, content}, [{"feed", _, _} | _], feed) do
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
    def on_end_element({unquote(tag_name), attributes, content}, [{"entry", _, _} | _], feed) do
      case extract_text(attributes, content) do
        {:ok, content} ->
          %{entries: [entry | entries]} = feed

          entry = Map.put(entry, unquote(key), content)

          %{feed | entries: [entry | entries]}

        {:error, _reason} -> feed
      end
    end
  end)

  def on_end_element({"link", _, _} = element, [{"entry", _, _} | _], feed) do
    %{entries: [entry | entries]} = feed

    link = Atom.Link.from_element(element)
    entry = Map.put(entry, :link, link)

    %{feed | entries: [entry | entries]}
  end

  def on_end_element(_element, _stack, feed) do
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
