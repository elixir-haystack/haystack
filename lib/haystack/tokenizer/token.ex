defmodule Haystack.Tokenizer.Token do
  @moduledoc """
  A module for Tokens.
  """

  # Types

  @type v :: String.t()
  @type opts :: [offset: integer, length: integer]
  @type t :: %__MODULE__{
          v: v,
          offset: integer,
          length: integer
        }

  @enforce_keys ~w{v offset length}a

  defstruct @enforce_keys

  # Public

  @doc """
  Create a new token.

  ## Examples

    iex> Token.new("abc", offset: 0, length: 3)

  """
  @spec new(String.t(), opts) :: t
  def new(v, opts) do
    struct(__MODULE__, [v: v] ++ opts)
  end
end
