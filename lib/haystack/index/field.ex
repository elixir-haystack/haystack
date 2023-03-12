defmodule Haystack.Index.Field do
  @moduledoc """
  A module for index fields.
  """

  alias Haystack.{Tokenizer, Transformer}

  @enforce_keys ~w{k path separator transformers}a

  defstruct @enforce_keys

  @type k :: String.t()
  @type t :: %__MODULE__{
          k: k,
          path: list(String.t()),
          separator: Regex.t(),
          transformers: list(module)
        }

  @doc """
  Create a new field.

  ## Examples

    iex> Index.Field.new("name")
    iex> Index.Field.new("address.line_1")

  """
  def new(k, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:k, k)
      |> Keyword.put(:path, String.split(k, "."))
      |> Keyword.put_new(:transformers, Transformer.default())
      |> Keyword.put_new(:separator, Tokenizer.separator(:default))

    struct(__MODULE__, opts)
  end

  @doc """
  Create a new "term" field.

  ## Examples

    iex> Index.Field.term("id")
    iex> Index.Field.term("address.postcode")

  """
  def term(k) do
    new(k, transformers: [], separator: Tokenizer.separator(:full))
  end
end
