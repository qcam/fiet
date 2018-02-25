defmodule Fiet.Atom.Person do
  @type t :: %__MODULE__{
          name: binary | nil,
          uri: binary | nil,
          email: binary | nil
        }

  defstruct [:name, :uri, :email]
end
