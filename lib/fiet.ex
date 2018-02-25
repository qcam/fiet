defmodule Fiet do
  @moduledoc """
  Fiet is a feeds parser in Elixir, which aims to provide extensibility, speed, and
  standard compliance to feed parsing.

  Currently Fiet supports the following formats:

  * `Fiet.RSS2`.
  """

  alias Fiet.{
    Atom,
    RSS2
  }

  @doc """
  Parses RSS binary into `Fiet.Feed`.
  """
  def parse(data) when is_binary(data) do
    case detect_format(data) do
      :atom -> parse_atom(data)
      :rss2 -> parse_rss2(data)
      :error -> {:error, "input data format is not supported"}
    end
  end

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
    end
  end
end
