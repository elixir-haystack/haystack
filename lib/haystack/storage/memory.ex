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

    iex> storage = Storage.Memory.new()
    iex> Storage.Memory.fetch(storage, :name)
    {:error, %Storage.NotFoundError{message: "Not found"}}

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> Storage.Memory.fetch(storage, :name)
    {:ok, "Haystack"}

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

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> Storage.Memory.fetch!(storage, :name)
    "Haystack"

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

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> Storage.Memory.fetch!(storage, :name)
    "Haystack"

  """
  @impl true
  def insert(storage, k, v) do
    Map.update!(storage, :data, &Map.put(&1, k, v))
  end

  @doc """
  Update an item in storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> Storage.Memory.update(storage, :name, &String.upcase/1)
    {:error, %Storage.NotFoundError{message: "Not found"}}

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> {:ok, storage} = Storage.Memory.update(storage, :name, &String.upcase/1)
    iex> Storage.Memory.fetch!(storage, :name)
    "HAYSTACK"

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

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> storage = Storage.Memory.update!(storage, :name, &String.upcase/1)
    iex> Storage.Memory.fetch!(storage, :name)
    "HAYSTACK"

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

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.upsert(storage, :name, "HAYSTACK", &String.upcase/1)
    iex> Storage.Memory.fetch!(storage, :name)
    "HAYSTACK"

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> storage = Storage.Memory.upsert(storage, :name, "HAYSTACK", &String.upcase/1)
    iex> Storage.Memory.fetch!(storage, :name)
    "HAYSTACK"

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

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.delete(storage, :name)
    iex> Storage.Memory.fetch(storage, :name)
    {:error, %Storage.NotFoundError{message: "Not found"}}

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.Memory.insert(storage, :name, "Haystack")
    iex> storage = Storage.Memory.delete(storage, :name)
    iex> Storage.Memory.fetch(storage, :name)
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
