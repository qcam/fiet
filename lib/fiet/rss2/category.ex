defmodule Fiet.RSS2.Category do
  @type t :: %__MODULE__{
          value: binary | nil,
          domain: binary | nil
        }

  defstruct [:value, :domain]
end
