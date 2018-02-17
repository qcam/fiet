defmodule Viet.StackParser do
  @behaviour Saxy.Handler

  def parse(document, state, handler) do
    init_state = {[], state, handler}

    case Saxy.parse_string(document, Viet.StackParser, init_state) do
      {:ok, {_stack, state, _handler}} -> {:ok, state}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_event(:start_element, {tag_name, attributes}, {stack, state, handler}) do
    element = {tag_name, attributes, []}

    new_state = handler.on_start_element(element, stack, state)

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
    new_state = handler.on_end_element(element, stack, state)

    {stack, new_state, handler}
  end

  def handle_event(_event_type, _event_data, state), do: state
end
