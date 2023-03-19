defmodule Haystack.Index do
  @moduledoc """
  A module for managing indexes.

  The index is used to manage configuration and acts as a central point to add,
  update, delete, or query the storage.
  """

  alias Haystack.{Index, Query, Storage, Tokenizer, Transformer}

  # Types

  @type attrs :: %{insert: list(module), delete: list(module)}
  @type fields :: %{Index.Field.k() => Index.Field.t()}
  @type opts :: Keyword.t()
  @type t :: %__MODULE__{
          attrs: attrs,
          fields: fields,
          name: atom,
          ref: Index.Field.t(),
          storage: struct()
        }

  @enforce_keys ~w{attrs fields name ref storage}a

  defstruct @enforce_keys

  # Public

  @doc """
  Create a new index.

  ## Examples

      iex> Index.new(:animals)

  """
  @spec new(atom, opts) :: t
  def new(name, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:name, name)
      |> Keyword.put(:fields, %{})
      |> Keyword.put_new(:storage, Storage.Map.new([]))
      |> Keyword.put_new(:attrs, Index.Attr.default())

    struct(__MODULE__, opts)
  end

  @doc """
  Set the attrs of the index.

  ## Examples

      iex> index = Index.new(:animals)
      iex> Index.attrs(index, %{insert: [Global], delete: [Global]})

  """
  @spec attrs(t, attrs) :: t
  def attrs(index, attrs),
    do: %{index | attrs: attrs}

  @doc """
  Add a ref to the index.

  ## Examples

      iex> index = Index.new(:animals)
      iex> Index.ref(index, Index.Field.new("id"))

  """
  @spec ref(t, Index.Field.t()) :: t
  def ref(index, ref),
    do: %{index | ref: ref}

  @doc """
  Add a field to the index.

  ## Examples

      iex> index = Index.new(:animals)
      iex> Index.field(index, Index.Field.new("name"))

  """
  @spec field(t, Index.Field.t()) :: t
  def field(index, field),
    do: %{index | fields: Map.put(index.fields, field.k, field)}

  @doc """
  Set the storage on the index.

  ## Examples

      iex> index = Index.new(:animals)
      iex> Index.storage(index, Storage.Map.new())

  """
  @spec storage(t, struct) :: t
  def storage(index, storage),
    do: %{index | storage: storage}

  @doc """
  Add documents to the index.

  ## Examples

      iex> index = Index.new(:animals)
      iex> Index.add(index, [])

  """
  @spec add(t, list(map)) :: t
  def add(index, data) do
    docs = Enum.map(data, &Index.Document.new(index, &1))

    Enum.reduce(docs, index, fn doc, index ->
      Enum.reduce(index.attrs.insert, index, fn module, index ->
        module.insert(index, doc)
      end)
    end)
  end

  @doc """
  Delete documents in the index.

  ## Examples

      iex> index = Index.new(:animals)
      iex> Index.delete(index, [])

  """
  @spec delete(t, list(map)) :: t
  def delete(index, data) do
    docs = Enum.map(data, &Index.Document.new(index, &1))

    Enum.reduce(docs, index, fn doc, index ->
      Enum.reduce(index.attrs.delete, index, fn module, index ->
        module.delete(index, doc)
      end)
    end)
  end

  @doc """
  Search the index.

    ## Examples

      iex> index = Index.new(:animals)
      iex> index = Index.field(index, Index.Field.new("name"))
      iex> Index.search(index, "red panda")

  """
  @spec search(t, String.t(), Keyword.t()) :: list(map)
  def search(index, v, opts \\ []) do
    type = Keyword.get(opts, :query, :match_any)
    tokens = Tokenizer.tokenize(v)
    tokens = Transformer.pipeline(tokens, Transformer.default())

    Query.new()
    |> Query.clause(Query.build(type, index, tokens))
    |> Query.run(index)
  end
end
