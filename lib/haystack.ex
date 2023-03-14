defmodule Haystack do
  @moduledoc """
  Haystack is a simple, extendable search engine written in Elixir.
  """

  alias Haystack.Index

  # Types

  @type t :: %__MODULE__{
          indexes: %{atom => Index.t()}
        }

  @enforce_keys ~w{indexes}a

  defstruct @enforce_keys

  # Public

  @doc """
  Create a new Haystack.

  ## Examples

    iex> Haystack.new()

  """
  @spec new(Keyword.t()) :: t
  def new(_opts \\ []),
    do: struct(__MODULE__, indexes: %{})

  @doc """
  Interact with the given index.

  ## Examples

    iex> haystack = Haystack.new()
    iex> Haystack.index(haystack, :animals, &Function.identity/1)

  """
  @spec index(t, atom, (Index.t() -> term)) :: t | term
  def index(hs, name, f) do
    case f.(Map.get(hs.indexes, name, Index.new(name))) do
      %Index{} = index -> %{hs | indexes: Map.put(hs.indexes, name, index)}
      response -> response
    end
  end
end
