defmodule Haystack.Tokenizer.Token do
  @moduledoc """
  A module for Tokens.
  """

  @type v :: String.t()
  @type opts :: [start: integer, length: integer]
  @type t :: %__MODULE__{
          v: v,
          start: integer,
          length: integer
        }

  @enforce_keys ~w{v start length}a

  defstruct @enforce_keys

  @doc """
  Create a new token.

  ## Examples

    iex> Token.new("abc", start: 0, length: 3)

  """
  @spec new(String.t(), opts) :: t
  def new(v, opts) do
    struct(__MODULE__, [v: v] ++ opts)
  end
end
