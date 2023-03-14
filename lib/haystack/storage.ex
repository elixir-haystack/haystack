defmodule Haystack.Storage do
  @moduledoc """
  A module and behaviour for storing data.

  This module acts as a convenient way to delegate to the storage implementation
  within Haystack.

  This has been created as a behaviour to make it easy to provide your own
  storage implementation. By default Haystack provides a memory storage
  implementation, which uses a map to store data.
  """

  # Types

  @type opts :: Keyword.t()
  @type t :: struct
  @type k :: term
  @type v :: term

  # Errors

  defmodule NotFoundError do
    @moduledoc false

    @type t :: %__MODULE__{message: String.t()}

    defexception ~w{message}a
  end

  # Behaviour

  @doc """
  Create a new storage.
  """
  @callback new(opts) :: t

  @doc """
  Fetch an item from storage.
  """
  @callback fetch(t, k) :: {:ok, v} | {:error, NotFoundError.t()}

  @doc """
  Fetch an item from storage.
  """
  @callback fetch!(t, k) :: v

  @doc """
  Insert an item into storage
  """
  @callback insert(t, k, v) :: t

  @doc """
  Update an item in storage.
  """
  @callback update(t, k, function) :: {:ok, t}

  @doc """
  Update an item in storage.
  """
  @callback update!(t, k, function) :: t

  @doc """
  Upsert an item in storage.
  """
  @callback upsert(t, k, v, function) :: t

  @doc """
  Delete an item from storage.
  """
  @callback delete(t, k) :: t

  @doc """
  Return the count of items in storage.
  """
  @callback count(t) :: integer

  @doc """
  Dump the storage to the filesystem.
  """
  @callback dump!(t, Path.t()) :: :ok

  @doc """
  Load the storage from the filesystem.
  """
  @callback load!(Path.t()) :: t

  # Public

  @doc """
  Fetch an item from storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> Storage.fetch(storage, :name)
    {:error, %Storage.NotFoundError{message: "Not found"}}

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> Storage.fetch(storage, :name)
    {:ok, "Haystack"}

  """
  @spec fetch(t, k) :: {:ok, v} | {:error, NotFoundError.t()}
  def fetch(storage, k),
    do: delegate(storage, :fetch, [k])

  @doc """
  Fetch an item from storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> Storage.fetch!(storage, :name)
    "Haystack"

  """
  @spec fetch!(t, k) :: v
  def fetch!(storage, k),
    do: delegate(storage, :fetch!, [k])

  @doc """
  Insert an item into storage

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> Storage.fetch!(storage, :name)
    "Haystack"

  """
  @spec insert(t, k, v) :: t
  def insert(storage, k, v),
    do: delegate(storage, :insert, [k, v])

  @doc """
  Update an item in storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> Storage.update(storage, :name, &String.upcase/1)
    {:error, %Storage.NotFoundError{message: "Not found"}}

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> {:ok, storage} = Storage.update(storage, :name, &String.upcase/1)
    iex> Storage.fetch!(storage, :name)
    "HAYSTACK"

  """
  @spec update(t, k, function) :: {:ok, t}
  def update(storage, k, f),
    do: delegate(storage, :update, [k, f])

  @doc """
  Update an item in storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> storage = Storage.update!(storage, :name, &String.upcase/1)
    iex> Storage.fetch!(storage, :name)
    "HAYSTACK"

  """
  @spec update!(t, k, function) :: t
  def update!(storage, k, f),
    do: delegate(storage, :update!, [k, f])

  @doc """
  Upsert an item in storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.upsert(storage, :name, "HAYSTACK", &String.upcase/1)
    iex> Storage.fetch!(storage, :name)
    "HAYSTACK"

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> storage = Storage.upsert(storage, :name, "HAYSTACK", &String.upcase/1)
    iex> Storage.fetch!(storage, :name)
    "HAYSTACK"

  """
  @spec upsert(t, k, v, function) :: t
  def upsert(storage, k, v, f),
    do: delegate(storage, :upsert, [k, v, f])

  @doc """
  Delete an item from storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.delete(storage, :name)
    iex> Storage.fetch(storage, :name)
    {:error, %Storage.NotFoundError{message: "Not found"}}

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> storage = Storage.delete(storage, :name)
    iex> Storage.fetch(storage, :name)
    {:error, %Storage.NotFoundError{message: "Not found"}}

  """
  @spec delete(t, k) :: t
  def delete(storage, k),
    do: delegate(storage, :delete, [k])

  @doc """
  Return the count of items in storage.

  ## Examples

    iex> storage = Storage.Memory.new()
    iex> storage = Storage.insert(storage, :name, "Haystack")
    iex> Storage.count(storage)
    1

  """
  @spec count(t) :: integer
  def count(storage),
    do: delegate(storage, :count, [])

  @doc """
  Dump the storage to the filesystem.
  """
  @spec dump!(t, Path.t()) :: :ok
  def dump!(storage, path),
    do: delegate(storage, :dump!, [path])

  # Private

  defp delegate(%module{} = storage, func, args),
    do: apply(module, func, [storage] ++ args)
end
