defmodule Haystack.Tokenizer.Token do
  @moduledoc """
  A module for Tokens.
  """

  @type t :: %__MODULE__{
          v: String.t(),
          start: integer,
          length: integer
        }

  @type opts :: [start: integer, length: integer]

  @enforce_keys ~w{v start length}a

  defstruct @enforce_keys

  @doc """
  Create a new token.

  ## Examples

    iex> Token.new("abc", start: 0, length: 3)
    %Token{v: "abc", start: 0, length: 3}

  """
  @spec new(String.t(), opts) :: t
  def new(v, opts) do
    struct(__MODULE__, [v: v] ++ opts)
  end
end
