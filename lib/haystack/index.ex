defmodule Haystack.Index do
  @moduledoc """
  A module for managing indexes.

  The index is used to manage configuration and acts as a central point to add,
  update, delete, or query the storage.
  """

  alias __MODULE__
  alias Haystack.{Query, Storage, Store}

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
      |> Keyword.put_new(:storage, Storage.Memory.new([]))
      |> Keyword.put_new(:attrs, Store.Attr.default())

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
    iex> Index.storage(index, Storage.Memory.new())

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
    data
    |> Enum.map(&Store.Document.new(index, &1))
    |> then(&Store.insert(index, &1))
  end

  @doc """
  Update documents in the index.

  ## Examples

    iex> index = Index.new(:animals)
    iex> Index.update(index, [])

  """
  @spec update(t, list(map)) :: t
  def update(index, data) do
    data
    |> Enum.map(&Store.Document.new(index, &1))
    |> then(&Store.update(index, &1))
  end

  @doc """
  Delete documents in the index.

  ## Examples

    iex> index = Index.new(:animals)
    iex> Index.delete(index, [])

  """
  @spec delete(t, list(map)) :: t
  def delete(index, refs),
    do: Store.delete(index, refs)

  @doc """
  Search the index.
  """
  @spec search(t, Query.t()) :: list(map)
  def search(index, %Query{} = query),
    do: Query.run(query, index)
end
