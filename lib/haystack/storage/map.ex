defmodule Haystack.Storage.Map do
  @moduledoc """
  A map implementation of the storage behaviour.
  """

  alias Haystack.Storage

  @behaviour Haystack.Storage

  # Types

  @type t :: %__MODULE__{data: %{term => term}}

  @enforce_keys ~w{data}a

  defstruct @enforce_keys

  # Haystack.Storage

  @doc """
  Create a new storage.

  ## Examples

      iex> Storage.Map.new()

  """
  @impl Haystack.Storage
  def new(_opts \\ []),
    do: struct(__MODULE__, data: %{})

  @doc """
  Fetch an item from storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> Storage.Map.fetch(storage, :name)
      {:error, %Storage.NotFoundError{message: "Not found"}}

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> Storage.Map.fetch(storage, :name)
      {:ok, "Haystack"}

  """
  @impl Haystack.Storage
  def fetch(storage, k) do
    case Map.fetch(storage.data, k) do
      {:ok, v} -> {:ok, v}
      :error -> {:error, %Storage.NotFoundError{message: "Not found"}}
    end
  end

  @doc """
  Fetch an item from storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> Storage.Map.fetch!(storage, :name)
      "Haystack"

  """
  @impl Haystack.Storage
  def fetch!(storage, k) do
    case fetch(storage, k) do
      {:ok, v} -> v
      {:error, error} -> raise error
    end
  end

  @doc """
  Insert an item into storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> Storage.Map.fetch!(storage, :name)
      "Haystack"

  """
  @impl Haystack.Storage
  def insert(storage, k, v),
    do: Map.update!(storage, :data, &Map.put(&1, k, v))

  @doc """
  Update an item in storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> Storage.Map.update(storage, :name, &String.upcase/1)
      {:error, %Storage.NotFoundError{message: "Not found"}}

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> {:ok, storage} = Storage.Map.update(storage, :name, &String.upcase/1)
      iex> Storage.Map.fetch!(storage, :name)
      "HAYSTACK"

  """
  @impl Haystack.Storage
  def update(storage, k, f) do
    with {:ok, v} <- fetch(storage, k) do
      {:ok, Map.update!(storage, :data, &Map.put(&1, k, f.(v)))}
    end
  end

  @doc """
  Update an item in storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> storage = Storage.Map.update!(storage, :name, &String.upcase/1)
      iex> Storage.Map.fetch!(storage, :name)
      "HAYSTACK"

  """
  @impl Haystack.Storage
  def update!(storage, k, f) do
    case update(storage, k, f) do
      {:ok, storage} -> storage
      {:error, error} -> raise error
    end
  end

  @doc """
  Upsert an item in storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.upsert(storage, :name, "HAYSTACK", &String.upcase/1)
      iex> Storage.Map.fetch!(storage, :name)
      "HAYSTACK"

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> storage = Storage.Map.upsert(storage, :name, "HAYSTACK", &String.upcase/1)
      iex> Storage.Map.fetch!(storage, :name)
      "HAYSTACK"

  """
  @impl Haystack.Storage
  def upsert(storage, k, v, f) do
    case update(storage, k, f) do
      {:ok, storage} -> storage
      {:error, _} -> insert(storage, k, v)
    end
  end

  @doc """
  Delete an item from storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.delete(storage, :name)
      iex> Storage.Map.fetch(storage, :name)
      {:error, %Storage.NotFoundError{message: "Not found"}}

      iex> storage = Storage.Map.new()
      iex> storage = Storage.Map.insert(storage, :name, "Haystack")
      iex> storage = Storage.Map.delete(storage, :name)
      iex> Storage.Map.fetch(storage, :name)
      {:error, %Storage.NotFoundError{message: "Not found"}}

  """
  @impl Haystack.Storage
  def delete(storage, k),
    do: Map.update!(storage, :data, &Map.delete(&1, k))

  @doc """
  Return the count of items in storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> storage = Storage.insert(storage, :name, "Haystack")
      iex> Storage.count(storage)
      1

  """
  @impl Haystack.Storage
  def count(storage),
    do: Enum.count(storage.data)

  @doc """
  Serialize the storage.

  ## Examples

      iex> storage = Storage.Map.new()
      iex> Storage.serialize(storage)

  """
  @impl Haystack.Storage
  def serialize(storage),
    do: :erlang.term_to_binary(storage)
end
