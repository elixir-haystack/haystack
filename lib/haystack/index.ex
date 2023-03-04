defmodule Haystack.Index do
  @moduledoc """
  A module for managing indexes.
  """

  alias __MODULE__
  alias Haystack.Storage

  @enforce_keys ~w{name ref fields}a

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          name: atom,
          ref: Index.Field.t(),
          fields: %{Index.Field.k() => Index.Field.t()}
        }

  @type opts :: Keyword.t()

  @doc """
  Create a new index.

  ## Examples

    iex> Index.new(:people)

  """
  @spec new(atom, opts) :: t
  def new(name, opts \\ []) do
    storage = Keyword.get(opts, :storage, Storage.Memory.new([]))

    struct(__MODULE__, name: name, fields: %{}, storage: storage)
  end

  @doc """
  Add a ref to the index.

  ## Examples

    iex> index = Index.new(:people)
    iex> Index.ref(index, Index.Field.new("id"))

  """
  @spec ref(t, Index.Field.t()) :: t
  def ref(index, ref) do
    %{index | ref: ref}
  end

  @doc """
  Add a field to the index.

  ## Examples

    iex> index = Index.new(:people)
    iex> Index.field(index, Index.Field.new("name"))

  """
  @spec field(t, Index.Field.t()) :: t
  def field(index, field) do
    %{index | fields: Map.put(index.fields, field.k, field)}
  end
end
