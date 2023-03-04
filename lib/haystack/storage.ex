defmodule Haystack.Storage do
  @moduledoc """
  A behaviour for storing data.
  """

  @type opts :: Keyword.t()
  @type storage :: struct
  @type k :: term
  @type v :: term

  defmodule NotFoundError do
    @moduledoc false

    @type t :: %__MODULE__{}

    defexception ~w{message}a
  end

  @doc """
  Create a new storage.
  """
  @callback new(opts) :: storage

  @doc """
  Fetch an item from storage.
  """
  @callback fetch(storage, k) :: {:ok, v} | {:error, NotFoundError.t()}

  @doc """
  Fetch an item from storage.
  """
  @callback fetch!(storage, k) :: v

  @doc """
  Insert an item into storage
  """
  @callback insert(storage, k, v) :: storage

  @doc """
  Update an item in storage.
  """
  @callback update(storage, k, function) :: {:ok, storage}

  @doc """
  Update an item in storage.
  """
  @callback update!(storage, k, function) :: storage

  @doc """
  Upsert an item in storage.
  """
  @callback upsert(storage, k, v, function) :: storage

  @doc """
  Delete an item from storage.
  """
  @callback delete(storage, k) :: storage

  @doc """
  Dump the storage to the filesystem.
  """
  @callback dump!(storage, Path.t()) :: :ok

  @doc """
  Load the storage from the filesystem.
  """
  @callback load!(Path.t()) :: storage
end
