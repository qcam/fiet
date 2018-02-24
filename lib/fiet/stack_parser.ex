defmodule Fiet.StackParser do
  @moduledoc false

  @behaviour Saxy.Handler

  def parse(document, state, handler) do
    init_state = {[], state, handler}

    case Saxy.parse_string(document, Fiet.StackParser, init_state) do
      {:ok, {_stack, state, _handler}} -> {:ok, state}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_event(:start_element, {tag_name, attributes}, {stack, state, handler}) do
    element = {tag_name, attributes, []}

    new_state = emit_event(:start_element, element, stack, state, handler)

    {[element | stack], new_state, handler}
  end

  def handle_event(:characters, chars, {stack, state, handler}) do
    [{tag_name, attributes, content} | stack] = stack
    element = {tag_name, attributes, [chars | content]}

    {[element | stack], state, handler}
  end

  def handle_event(:reference, ref, {stack, state, handler}) do
    [{tag_name, attributes, content} | stack] = stack
    element = {tag_name, attributes, [ref | content]}

    {[element | stack], state, handler}
  end

  def handle_event(:end_element, {tag_name}, {stack, state, handler}) do
    [{^tag_name, attributes, content} | stack] = stack

    content = content |> Enum.reverse() |> Enum.join("")
    attributes = Enum.reverse(attributes)
    element = {tag_name, attributes, content}
    new_state = emit_event(:end_element, element, stack, state, handler)

    {stack, new_state, handler}
  end

  def handle_event(_event_type, _event_data, state), do: state

  defp emit_event(event_type, event_data, stack, state, handler) when is_atom(handler) do
    handler.handle_event(event_type, event_data, stack, state)
  end

  defp emit_event(event_type, event_data, stack, state, handler) when is_function(handler) do
    handler.(event_type, event_data, stack, state)
  end
end
