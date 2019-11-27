defmodule Fiet do
  @moduledoc """
  Fiet is a feed parser which aims to provide extensibility, speed, and standard
  compliance.

  Currently Fiet supports [RSS 2.0](cyber.harvard.edu/rss/rss.html) and [Atom](https://tools.ietf.org/html/rfc4287).

  ## Feed format detecting

  There are two main functions in this module: `parse/1` and `parse!/1`, which
  provide detecting parsing. That means that it will detect the format of the
  XML document input then parse and map it into `Fiet.Feed`, which is the
  unified format of all the feed formats supported by Fiet.

  Please note that detecting logic works by checking the root tag of the XML
  document, it does not mean to validate the XML document.

  ## Detecting overhead

  If you know exactly the feed format of the XML document you are going to parse,
  you are recommended to use `Fiet.Atom` or `Fiet.RSS2` to avoid overhead. That
  will give you the full data parsed from the feed document.

  """

  alias Fiet.{
    Atom,
    RSS2
  }

  @doc """
  Parse RSS document into a feed.

  ## Example

      rss = File.read!("/path/to/rss")
      {:ok, %Fiet.Feed{} = feed} = Fiet.parse(rss)

  """

  @spec parse(data :: binary) :: {:ok, feed :: Fiet.Feed.t()} | {:error, reason :: any}
  def parse(data) when is_binary(data) do
    case detect_format(data) do
      :atom -> parse_atom(data)
      :rss2 -> parse_rss2(data)
      :error -> {:error, "input data format is not supported"}
    end
  end

  @doc """
  Same as `parse/1`, but this will raise when error happen.

  ## Example

      rss = File.read!("/path/to/rss")
      %Fiet.Feed{} = Fiet.parse(rss)
  """

  @spec parse!(data :: binary) :: Fiet.Feed.t()
  def parse!(data) do
    case parse(data) do
      {:ok, feed} ->
        feed

      {:error, %module{} = error} when module in [RSS2.Engine.ParsingError, Atom.ParsingError] ->
        raise(error)

      {:error, message} ->
        raise RuntimeError, message
    end
  end

  defp parse_rss2(data) do
    case RSS2.parse(data) do
      {:ok, %RSS2.Channel{} = channel} ->
        {:ok, Fiet.Feed.new(channel)}

      {:error, _reason} = error ->
        error
    end
  end

  defp parse_atom(data) do
    case Atom.parse(data) do
      {:ok, %Atom.Feed{} = feed} ->
        {:ok, Fiet.Feed.new(feed)}

      {:error, _reason} = error ->
        error
    end
  end

  defp detect_format(data) do
    Fiet.StackParser.parse(data, [], fn
      :start_element, {"feed", _, _}, [], _ ->
        {:stop, :atom}

      :start_element, {"rss", _, _}, [], _ ->
        {:stop, :rss2}

      :start_element, _other, [], _ ->
        {:stop, false}
    end)
    |> case do
      {:ok, false} -> :error
      {:ok, type} -> type
      {:error, _reason} -> :error
    end
  end
end
