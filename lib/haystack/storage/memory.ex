defmodule Haystack.Storage.Memory do
  @moduledoc """
  An in-memory implementation of the storage behaviour.
  """

  alias Haystack.Storage

  @behaviour Haystack.Storage

  @type t :: %__MODULE__{
          data: %{term => term}
        }

  @enforce_keys ~w{data}a

  defstruct @enforce_keys

  @doc """
  Create a new storage.

  ## Examples

    iex> Storage.Memory.new()

  """
  @impl true
  def new(_opts \\ []) do
    struct(__MODULE__, data: %{})
  end

  @doc """
  Fetch an item from storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> Storage.Memory.fetch(s, :a)
    {:ok, "a"}

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> Storage.Memory.fetch(s, :b)
    {:error, %Storage.NotFoundError{message: "Not found"}}

  """
  @impl true
  def fetch(storage, k) do
    case Map.fetch(storage.data, k) do
      {:ok, v} -> {:ok, v}
      :error -> {:error, %Storage.NotFoundError{message: "Not found"}}
    end
  end

  @doc """
  Fetch an item from storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> Storage.Memory.fetch!(s, :a)
    "a"

  """
  @impl true
  def fetch!(storage, k) do
    case fetch(storage, k) do
      {:ok, v} -> v
      {:error, error} -> raise error
    end
  end

  @doc """
  Insert an item into storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> Storage.Memory.fetch!(s, :a)
    "a"

  """
  @impl true
  def insert(storage, k, v) do
    Map.update!(storage, :data, &Map.put(&1, k, v))
  end

  @doc """
  Update an item in storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> {:ok, s} = Storage.Memory.update(s, :a, & &1 <> &1)
    iex> Storage.Memory.fetch!(s, :a)
    "aa"

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> Storage.Memory.update(s, :b, & &1 <> &1)
    iex> {:error, %Storage.NotFoundError{message: "Not found"}}

  """
  @impl true
  def update(storage, k, f) do
    with {:ok, v} <- fetch(storage, k) do
      {:ok, Map.update!(storage, :data, &Map.put(&1, k, f.(v)))}
    end
  end

  @doc """
  Update an item in storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> s = Storage.Memory.update!(s, :a, & &1 <> &1)
    iex> Storage.Memory.fetch!(s, :a)
    "aa"

  """
  @impl true
  def update!(storage, k, f) do
    case update(storage, k, f) do
      {:ok, storage} -> storage
      {:error, error} -> raise error
    end
  end

  @doc """
  Upsert an item in storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.upsert(s, :a, "a", fn _ -> "a" end)
    iex> Storage.Memory.fetch!(s, :a)
    "a"

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a1")
    iex> s = Storage.Memory.upsert(s, :a, "a2", fn _ -> "a2" end)
    iex> Storage.Memory.fetch!(s, :a)
    "a2"

  """
  @impl true
  def upsert(storage, k, v, f) do
    case update(storage, k, f) do
      {:ok, storage} -> storage
      {:error, _} -> insert(storage, k, v)
    end
  end

  @doc """
  Delete an item from storage.

  ## Examples

    iex> s = Storage.Memory.new()
    iex> s = Storage.Memory.insert(s, :a, "a")
    iex> s = Storage.Memory.delete(s, :a)
    iex> Storage.Memory.fetch(s, :a)
    {:error, %Storage.NotFoundError{message: "Not found"}}

  """
  @impl true
  def delete(storage, k) do
    Map.update!(storage, :data, &Map.delete(&1, k))
  end

  @doc """
  Dump the storage to the filesystem.
  """
  @impl true
  def dump!(storage, path) do
    File.write!(path, :erlang.term_to_binary(storage))
  end

  @doc """
  Load the storage from the filesystem.
  """
  @impl true
  def load!(path) do
    :erlang.binary_to_term(File.read!(path))
  end
end
