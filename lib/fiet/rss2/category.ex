defmodule Fiet.RSS2.Category do
  @type t :: %__MODULE__{
    value: binary,
    domain: binary
  }

  defstruct [:value, :domain]
end
