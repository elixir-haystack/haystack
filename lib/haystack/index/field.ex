defmodule Haystack.Index.Field do
  @moduledoc """
  A module for index fields.

  This module allows you to configure the fields of the index. Each field can
  have a customised set of transformers and a custom regex used for tokenizing.
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

  You can include nested fields using dot syntax. The field accepts an optional
  list of transformers to be used as well as a regex used for tokenizing.

  ## Examples

      iex> field = Index.Field.new("name")
      iex> field.k
      "name"

      iex> field = Index.Field.new("address.line_1")
      iex> field.path
      ["address", "line_1"]

  """
  @spec new(k, Keyword.t()) :: t
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

  A term field is a field that shouldn't be tokenized or transformed. For
  example, an ID, serial code, etc.

  ## Examples

      iex> field = Index.Field.term("id")
      iex> field.transformers
      []

  """
  @spec term(k) :: t
  def term(k) do
    new(k, transformers: [], separator: Tokenizer.separator(:full))
  end
end
